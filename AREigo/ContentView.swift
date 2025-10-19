//
//  ContentView.swift
//  AREigo
//
//  Created by Gen Ichihashi on 2025-10-19.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: DetectorModel
    @State private var showSaved = false
    @State private var showHUD: SavedHUD? = nil

    var body: some View {
        ZStack {
            ARViewContainer()
                .environmentObject(model)
                .edgesIgnoringSafeArea(.all)

            // Detection overlay
            DetectionOverlay(
                observations: model.observations,
                onTap: { obs in
                    let item = model.save(observation: obs)
                    showHUD = SavedHUD(wordEN: item.english, wordJA: item.japanese)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { showHUD = nil }
                }
            )

            // Top controls
            VStack {
                HStack {
                    Spacer()
                    Button {
                        showSaved = true
                    } label: {
                        Label("Saved", systemImage: "bookmark")
                            .padding(10)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                    .padding(.top, 14).padding(.trailing, 14)
                }
                Spacer()
            }

            if let hud = showHUD {
                VStack {
                    Text("Saved")
                        .font(.caption2).padding(.top, 8)
                    Text("\(hud.wordEN) / \(hud.wordJA)")
                        .font(.callout).bold()
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                .transition(.opacity)
            }
        }
        .sheet(isPresented: $showSaved) {
            SavedListView()
                .environmentObject(model)
        }
    }

    struct SavedHUD: Identifiable {
        let id = UUID()
        let wordEN: String
        let wordJA: String
    }
}

#Preview {
    ContentView().environmentObject(DetectorModel())
}
