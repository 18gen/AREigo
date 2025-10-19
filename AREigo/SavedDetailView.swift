//
//  SavedDetailView.swift
//  AREigo
//
//  Created by Gen Ichihashi on 2025-10-19.
//

import SwiftUI
import UIKit

struct SavedDetailView: View {
    let item: VocabItem
    @State private var sharePresented = false

    private var image: UIImage? {
        if let fname = item.imageFilename {
            return UIImage(contentsOfFile: VocabStore.thumbnailURL(for: fname).path)
        }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.secondary.opacity(0.3)))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12).fill(.secondary.opacity(0.15))
                        Image(systemName: "photo")
                            .imageScale(.large)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 220)
                }

                // Bilingual title
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.english)
                        .font(.title).bold()
                    Text(item.japanese)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Meta info (fixed)
                HStack(spacing: 16) {
                    Label("Seen \(item.count)x", systemImage: "eye")

                    Label {
                        Text(item.firstSavedAt, style: .date)
                    } icon: {
                        Image(systemName: "calendar")
                    }

                    Label {
                        Text(item.lastSeenAt, style: .date)
                    } icon: {
                        Image(systemName: "clock")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Spacer(minLength: 20)
            }
            .padding()
        }
        .navigationTitle("Detail / 詳細")
        .toolbar {
            if let img = image {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(
                        item: Image(uiImage: img),
                        preview: SharePreview("\(item.english) / \(item.japanese)",
                                              image: Image(uiImage: img))
                    )
                }
            }
        }
    }
}
