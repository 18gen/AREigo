//
//  VocabStore.swift
//  AREigo
//
//  Created by Gen Ichihashi on 2025-10-19.
//

import Foundation

struct VocabItem: Identifiable, Codable {
    var id = UUID()
    var english: String
    var japanese: String
    var count: Int
    var firstSavedAt: Date
    var lastSeenAt: Date
}

final class VocabStore {
    private let url: URL

    init(filename: String = "saved_vocab.json") {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.url = docs.appendingPathComponent(filename)
    }

    func load() -> [VocabItem] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        do {
            return try JSONDecoder().decode([VocabItem].self, from: data)
        } catch {
            return []
        }
    }

    func save(_ items: [VocabItem]) {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Failed to save vocab: \(error)")
        }
    }
}
