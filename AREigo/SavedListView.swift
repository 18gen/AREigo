//
//  SavedListView.swift
//  AREigo
//
//  Created by Gen Ichihashi on 2025-10-19.
//

import SwiftUI

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
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(item.english) / \(item.japanese)")
                                .font(.headline)
                            Text("Seen \(item.count)x")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(item.lastSeenAt, style: .date)
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                }
                .onDelete(perform: delete)
            }
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .automatic))
            .navigationTitle("Saved")
            .toolbar {
                EditButton()
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        model.saved.remove(atOffsets: offsets)
        VocabStore().save(model.saved)
    }
}
