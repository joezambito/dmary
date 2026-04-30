//
//  MaryLanguageInterpreter.swift
//  Mary
//
//  Created by Joe Zambito on 27/4/2026.
//

import Foundation

struct MaryUnderstanding {
    let originalMessage: String
    let understoodMeaning: String
    let confidence: Double
    let needsClarification: Bool
    let clarificationQuestion: String?
    let needsCode: Bool
    let needsFileReading: Bool
    let needsResearch: Bool
}

/// This is a Passive Decoder. It does not contain its own AI prompts.
/// It simply takes the Main Brain's output and turns it into a usable Object.
struct MaryLanguageInterpreter {

    /// CLEANED: This no longer runs its own hidden 'AI Interpret' prompt.
    /// The Main Brain now handles the AI call; this just decodes the result.
    static func decodeUnderstanding(from rawJSON: String, originalMessage: String) -> MaryUnderstanding {
        let cleaned = rawJSON.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // JSON Guard: Extracts bracketed content
        guard let start = cleaned.firstIndex(of: "{"),
              let end = cleaned.lastIndex(of: "}"),
              let data = String(cleaned[start...end]).data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            
            // Minimalist fallback. No guessing logic allowed here.
            return MaryUnderstanding(
                originalMessage: originalMessage,
                understoodMeaning: originalMessage,
                confidence: 0.0,
                needsClarification: false,
                clarificationQuestion: nil,
                needsCode: false,
                needsFileReading: false,
                needsResearch: false
            )
        }

        return MaryUnderstanding(
            originalMessage: originalMessage,
            understoodMeaning: json["understoodMeaning"] as? String ?? originalMessage,
            confidence: json["confidence"] as? Double ?? 0.0,
            needsClarification: json["needsClarification"] as? Bool ?? false,
            clarificationQuestion: json["clarificationQuestion"] as? String,
            needsCode: json["needsCode"] as? Bool ?? false,
            needsFileReading: json["needsFileReading"] as? Bool ?? false,
            needsResearch: json["needsResearch"] as? Bool ?? false
        )
    }
}
