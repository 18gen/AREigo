//
//  DetectorModel.swift
//  AREigo
//
//  Created by Gen Ichihashi on 2025-10-19.
//

import Foundation
import Vision
import CoreML
import ARKit
import SwiftUI

struct Detection: Identifiable, Equatable {
    let id = UUID()
    let english: String
    let japanese: String
    let rectOnScreen: CGRect   // screen-space rect (points)
    let confidence: Float
}

final class DetectorModel: ObservableObject {
    @Published var observations: [Detection] = []
    @Published var saved: [VocabItem] = []

    private let translator = LabelTranslator()
    private let store = VocabStore()
    private let visionQueue = DispatchQueue(label: "vision.detect.queue")

    // Throttle (~8 Hz)
    private var isBusy = false
    private var lastFrameTime: CFTimeInterval = 0

    // Runtime-loaded Core ML detector (optional)
    private var vnModel: VNCoreMLModel?
    private let modelResourceCandidates = [
        "ObjectDetector",       // rename your .mlmodel to this for zero-config
        "YOLOv3Tiny",
        "SSD_MobileNet",
        "MobileNetV2_SSDLite"
    ]

    init() {
        self.saved = store.load()
        loadModelIfNeeded()
    }

    // Try to locate a compiled .mlmodelc in the app bundle and make a VNCoreMLModel
    private func loadModelIfNeeded() {
        guard vnModel == nil else { return }
        let bundle = Bundle.main
        for name in modelResourceCandidates {
            if let url = bundle.url(forResource: name, withExtension: "mlmodelc") {
                do {
                    let mlModel = try MLModel(contentsOf: url)
                    // ✅ FIX: correct initializer label is `for:`
                    vnModel = try VNCoreMLModel(for: mlModel)
                    return
                } catch {
                    print("Failed to load \(name): \(error)")
                }
            }
        }
        print("⚠️ No object detector model found. Falling back to image classification (no boxes).")
    }

    /// Process a frame from ARKit. Heavy work runs on `visionQueue`.
    func process(frame: ARFrame, viewSize: CGSize) {
        // Throttle to control CPU/GPU
        let t = frame.timestamp
        if isBusy || (t - lastFrameTime) < 0.12 { return }
        lastFrameTime = t
        isBusy = true

        let pixelBuffer = frame.capturedImage
        let orientation: CGImagePropertyOrientation = .right // portrait

        visionQueue.async { [weak self] in
            guard let self else { return }

            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                orientation: orientation,
                                                options: [:])

            if let vnModel = self.vnModel {
                // Use your CoreML detector (expects VNRecognizedObjectObservation for boxes)
                let request = VNCoreMLRequest(model: vnModel) { req, err in
                    defer { self.isBusy = false }
                    guard err == nil else {
                        DispatchQueue.main.async { self.observations = [] }
                        return
                    }

                    if let objs = req.results as? [VNRecognizedObjectObservation] {
                        let dets: [Detection] = objs.compactMap { ob in
                            guard let top = ob.labels.first else { return nil }
                            let en = top.identifier
                            let ja = self.translator.japanese(for: en)
                            let rect = Self.visionRectToViewRect(ob.boundingBox, viewSize: viewSize)
                            return Detection(english: en,
                                             japanese: ja,
                                             rectOnScreen: rect,
                                             confidence: top.confidence)
                        }
                        DispatchQueue.main.async {
                            self.observations = Self.reduceOverlaps(dets)
                        }
                    } else if let classes = req.results as? [VNClassificationObservation],
                              let top = classes.first {
                        // Some models output classifications only; show a centered pill
                        let rect = CGRect(x: viewSize.width * 0.3,
                                          y: viewSize.height * 0.35,
                                          width: viewSize.width * 0.4,
                                          height: viewSize.height * 0.3)
                        let en = top.identifier
                        let ja = self.translator.japanese(for: en)
                        let det = Detection(english: en,
                                            japanese: ja,
                                            rectOnScreen: rect,
                                            confidence: top.confidence)
                        DispatchQueue.main.async { self.observations = [det] }
                    } else {
                        DispatchQueue.main.async { self.observations = [] }
                    }
                }
                request.imageCropAndScaleOption = .scaleFill

                do {
                    try handler.perform([request])
                } catch {
                    DispatchQueue.main.async {
                        self.isBusy = false
                        self.observations = []
                    }
                }
            } else {
                // Fallback: built-in image classification (no boxes)
                let classify = VNClassifyImageRequest { req, err in
                    defer { self.isBusy = false }
                    guard err == nil,
                          let top = (req.results as? [VNClassificationObservation])?.first
                    else {
                        DispatchQueue.main.async { self.observations = [] }
                        return
                    }
                    let rect = CGRect(x: viewSize.width * 0.3,
                                      y: viewSize.height * 0.35,
                                      width: viewSize.width * 0.4,
                                      height: viewSize.height * 0.3)
                    let en = top.identifier
                    let ja = self.translator.japanese(for: en)
                    let det = Detection(english: en,
                                        japanese: ja,
                                        rectOnScreen: rect,
                                        confidence: top.confidence)
                    DispatchQueue.main.async { self.observations = [det] }
                }

                do {
                    try handler.perform([classify])
                } catch {
                    DispatchQueue.main.async {
                        self.isBusy = false
                        self.observations = []
                    }
                }
            }
        }
    }

    func save(observation: Detection) -> VocabItem {
        if let idx = saved.firstIndex(where: { $0.english.lowercased() == observation.english.lowercased() }) {
            var item = saved[idx]
            item.count += 1
            item.lastSeenAt = Date()
            saved[idx] = item
            store.save(saved)
            return item
        } else {
            let new = VocabItem(english: observation.english,
                                japanese: observation.japanese,
                                count: 1,
                                firstSavedAt: Date(),
                                lastSeenAt: Date())
            saved.insert(new, at: 0)
            store.save(saved)
            return new
        }
    }

    // MARK: - Helpers

    private static func visionRectToViewRect(_ box: CGRect, viewSize: CGSize) -> CGRect {
        // Vision: normalized, origin at bottom-left.
        let w = box.width * viewSize.width
        let h = box.height * viewSize.height
        let x = box.minX * viewSize.width
        let y = (1 - box.minY - box.height) * viewSize.height
        return CGRect(x: x, y: y, width: w, height: h)
    }

    private static func iou(_ a: CGRect, _ b: CGRect) -> CGFloat {
        let inter = a.intersection(b)
        if inter.isNull { return 0 }
        let interArea = inter.width * inter.height
        let unionArea = a.width*a.height + b.width*b.height - interArea
        return unionArea > 0 ? interArea / unionArea : 0
    }

    private static func reduceOverlaps(_ dets: [Detection]) -> [Detection] {
        var result: [Detection] = []
        for d in dets.sorted(by: { $0.confidence > $1.confidence }) {
            if !result.contains(where: { $0.english == d.english && iou($0.rectOnScreen, d.rectOnScreen) > 0.4 }) {
                result.append(d)
            }
        }
        return result
    }
}
