//
//  DetectionOverlay.swift
//  AREigo
//
//  Created by Gen Ichihashi on 2025-10-19.
//

import SwiftUI

struct DetectionOverlay: View {
    let observations: [Detection]
    var onTap: (Detection) -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(observations) { ob in
                    DetectionBox(observation: ob)
                        .onTapGesture { onTap(ob) }
                }
            }
            .allowsHitTesting(true)
        }
        .ignoresSafeArea()
    }
}

private struct DetectionBox: View {
    let observation: Detection

    var body: some View {
        let r = observation.rectOnScreen

        return ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(.white.opacity(0.9), lineWidth: 2)
                .background(RoundedRectangle(cornerRadius: 8).fill(.black.opacity(0.15)))
                .frame(width: max(1, r.width), height: max(1, r.height))
                .position(x: r.midX, y: r.midY)

            // Label bubble
            VStack(alignment: .leading, spacing: 2) {
                Text(observation.english)
                    .font(.caption).bold().foregroundStyle(.white)
                Text(observation.japanese)
                    .font(.caption2).foregroundStyle(.white.opacity(0.95))
                Text(String(format: "%.0f%%", observation.confidence * 100))
                    .font(.caption2).foregroundStyle(.white.opacity(0.7))
            }
            .padding(.horizontal, 8).padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
            .offset(x: r.minX + 6, y: r.minY - 28)
        }
    }
}
