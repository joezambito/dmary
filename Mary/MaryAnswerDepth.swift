//
//  MaryAnswerDepth.swift
//  Mary
//
//  Created by Joe Zambito on 26/4/2026.
//

import Foundation

/// THE THROTTLE: Controls the inference depth and token budget for the local LLM.
enum MaryAnswerDepth: String, CaseIterable, Identifiable {
    case basic = "Basic"
    case normal = "Normal"
    case deep = "Deep"

    var id: String { rawValue }

    /// The maximum token limit for the local backend on M2 Silicon.
    var maxTokens: Int {
        switch self {
        case .basic: return 512    // Snappy, direct fixes
        case .normal: return 1536  // Balanced reasoning
        case .deep: return 4096    // Full architectural analysis
        }
    }

    /// Technical directive to be injected into the PromptBuilder.
    var directive: String {
        switch self {
        case .basic:
            return "Be concise. Use short code snippets. Prioritize speed."
        case .normal:
            return "Provide balanced reasoning. Explain the 'why' before the 'how'."
        case .deep:
            return "Perform a deep architectural review. Consider edge cases and M2 performance."
        }
    }
}
