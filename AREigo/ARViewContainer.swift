//
//  ARViewContainer.swift
//  AREigo
//
//  Created by Gen Ichihashi on 2025-10-19.
//

import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var model: DetectorModel

    func makeCoordinator() -> Coordinator { Coordinator(model: model) }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.automaticallyConfigureSession = false

        let config = ARWorldTrackingConfiguration()
        config.providesAudioData = false
        config.environmentTexturing = .automatic
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])

        arView.session.delegate = context.coordinator
        context.coordinator.attach(arView)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    final class Coordinator: NSObject, ARSessionDelegate {
        private weak var arView: ARView?
        private let model: DetectorModel

        init(model: DetectorModel) { self.model = model }

        func attach(_ v: ARView) { self.arView = v }

        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            guard let arView = arView else { return }
            let size = arView.bounds.size
            model.process(frame: frame, viewSize: size)
        }

        func session(_ session: ARSession, didFailWithError error: Error) {
            print("ARSession failed: \(error)")
        }
    }
}
