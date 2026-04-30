//
//  MaryMemory.swift
//  Mary
//
//  Created by Joe Zambito on 27/4/2026.
//

import Foundation

final class MaryMemory {
    static let shared = MaryMemory()
    private var messages: [String] = []

    // 🏎️ This adds a message to Mary's active brain
    func add(_ message: String) {
        var processedMessage = message
        
        // NITRO LIMIT: 1,500 chars keeps the GPU response instant
        if processedMessage.count > 1500 {
            processedMessage = String(processedMessage.prefix(1500)) + "...[Turbo Truncated]"
        }
        
        messages.append(processedMessage)

        // LEAN HISTORY: 8 messages prevents the "23-second" memory overflow
        if messages.count > 8 {
            messages.removeFirst()
        }
    }

    // 🧠 This gives the AI the "Story so far"
    func recentContext(limit: Int) -> String {
        let contextLimit = min(limit, 5)
        let history = messages.suffix(contextLimit).joined(separator: "\n---\n")
        
        // If history is empty, tell her she's starting fresh with Joe
        if history.isEmpty {
            return "Joe has just started a new session. No previous context."
        }
        return history
    }

    func clear() {
        messages.removeAll()
    }
}
