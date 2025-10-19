//
//  AREigoApp.swift
//  AREigo
//
//  Created by Gen Ichihashi on 2025-10-19.
//

import SwiftUI

@main
struct AREigoApp: App {
    @StateObject private var model = DetectorModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}
