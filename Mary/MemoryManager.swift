//
//  MemoryManager.swift
//  Mary
//
//  Created by Joe Zambito on 25/4/2026.
//

import Foundation

/// CLEANED: A background actor for persistent memory.
/// Offloads disk I/O from the M2 Pro's main thread to prevent UI micro-stutters.
actor MemoryManager {
    private let fileName = "mary_memory.json"
    private let maxMessages = 10
    private let charLimit = 1500

    private var fileURL: URL {
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent(fileName)
    }

    /// CLEANED: Async load to keep the interface fluid.
    func load() async -> [String] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([String].self, from: data)
            return Array(decoded.suffix(maxMessages))
        } catch {
            return []
        }
    }

    /// CLEANED: Atomic background save.
    func save(messages: [String]) async {
        // Filter out errors and empty states
        let validMessages = messages.filter { !$0.contains("BACKEND_ERROR") && !$0.isEmpty }
        
        let toSave = validMessages.suffix(maxMessages).map { msg in
            msg.count > charLimit ? String(msg.prefix(charLimit)) + "..." : msg
        }

        do {
            let data = try JSONEncoder().encode(toSave)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Passive failure: memory just isn't persisted this time.
        }
    }

    func clear() async {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
