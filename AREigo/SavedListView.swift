//
//  SavedListView.swift
//  AREigo
//
//  Created by Gen Ichihashi on 2025-10-19.
//

import SwiftUI
import UIKit

struct SavedListView: View {
    @EnvironmentObject private var model: DetectorModel
    @State private var query = ""

    var filtered: [VocabItem] {
        guard !query.isEmpty else { return model.saved }
        return model.saved.filter {
            $0.english.localizedCaseInsensitiveContains(query) ||
            $0.japanese.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { item in
                    HStack(alignment: .center, spacing: 12) {
                        ThumbnailView(filename: item.imageFilename)
                            .frame(width: 56, height: 56)

                        VStack(alignment: .leading, spacing: 4) {
                            // Bilingual emphasis
                            Text("\(item.english) / \(item.japanese)")
                                .font(.headline)

                            HStack(spacing: 12) {
                                Label("Seen \(item.count)x", systemImage: "checkmark.circle")
                                    .font(.caption).foregroundStyle(.secondary)
                                Text(item.lastSeenAt, style: .date)
                                    .font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: delete)
            }
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .automatic))
            .navigationTitle("Saved / 保存済み")
            .toolbar {
                EditButton()
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        // Remove thumbnails from disk as well
        let itemsToDelete = offsets.map { filtered[$0] }
        for item in itemsToDelete {
            if let fname = item.imageFilename {
                let url = VocabStore.thumbnailURL(for: fname)
                try? FileManager.default.removeItem(at: url)
            }
        }
        // Remove from the source array keeping filter consistent
        let ids = Set(itemsToDelete.map { $0.id })
        model.saved.removeAll { ids.contains($0.id) }
        VocabStore().save(model.saved)
    }
}

private struct ThumbnailView: View {
    let filename: String?

    var body: some View {
        if let filename,
           let uiImage = UIImage(contentsOfFile: VocabStore.thumbnailURL(for: filename).path) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary.opacity(0.3), lineWidth: 0.5))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.secondary.opacity(0.15))
                Image(systemName: "photo")
                    .imageScale(.medium)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
