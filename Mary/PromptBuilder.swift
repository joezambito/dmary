//
//  PromptBuilder.swift
//  Mary
//
//  Created by Joe Zambito on 25/4/2026.
//

import Foundation

/// CLEANED: A precision prompt assembler.
/// Optimized for the M2 Pro to ensure the highest context density with lowest token waste.
struct PromptBuilder {

    static func buildPrompt(
        userMessage: String,
        terminalContext: String = "",
        recentConversation: String = "",
        projectMemory: String = ""
    ) -> String {
        
        // 🏎️ Priority Truncation: Keeps the 'End' of logs (where the errors are).
        let user = userMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        let terminal = tail(terminalContext, limit: 3000)
        let recent = tail(recentConversation, limit: 1000)
        let memory = head(projectMemory, limit: 1500)

        var sections: [String] = []

        // 1. Project Directives (Static/Persistent)
        if !memory.isEmpty {
            sections.append("### PROJECT MEMORY\n\(memory)")
        }

        // 2. Conversation Flow (Temporal)
        if !recent.isEmpty {
            sections.append("### RECENT HISTORY\n\(recent)")
        }

        // 3. The Evidence (Technical)
        if !terminal.isEmpty {
            sections.append("### TERMINAL EVIDENCE\n\(terminal)")
        }

        // 4. The Trigger (Immediate)
        sections.append("### JOE'S REQUEST\n\(user)")

        return sections.joined(separator: "\n\n---\n\n")
    }

    static func buildRetryPrompt(reason: String) -> String {
        return "RETRY INSTRUCTION: Your last response triggered a safety/format error: \(reason). Please correct your logic and re-emit the Swift code."
    }

    /// Truncates from the front to keep the LATEST logs.
    private static func tail(_ text: String, limit: Int) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count > limit {
            return "...[Logs Truncated]...\n" + String(trimmed.suffix(limit))
        }
        return trimmed
    }

    /// Truncates from the back to keep the CORE rules.
    private static func head(_ text: String, limit: Int) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count > limit {
            return String(trimmed.prefix(limit)) + "\n...[Rules Truncated]..."
        }
        return trimmed
    }
}
