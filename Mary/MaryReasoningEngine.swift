//
//  MaryReasoningEngine.swift
//  Mary
//
//  Created by Joe Zambito on 26/4/2026.
//

import Foundation
import Combine

/// THE ENGINE: Manages the depth of reasoning for every user turn.
final class MaryReasoningEngine: ObservableObject {
    @Published var thoughts: String = ""

    
    /// Analyzes the message to determine how much "Brain Power" to allocate.
    func analyzeComplexity(for message: String) -> MaryWorkMode {
        MaryBrain.determineDepth(for: message)
    }
    @Published var currentMode: MaryWorkMode = .normal

    func reset() {
        thoughts = ""
        currentMode = .normal
    }
    /// Generates high-rigidity system instructions based on the selected mode.
    func getContextInstructions(for mode: MaryWorkMode) -> String {
        let base = "You are Mary, an expert Swift/macOS engineer."

        switch mode {
        case .basic:
            return "\(base) Mode: Basic. Focus on speed and direct syntax fixes. No long explanations."
        case .normal:
            return "\(base) Mode: Normal. Provide functional code with brief architectural context."
        case .complex:
            return "\(base) Mode: Complex. Perform a full system-wide analysis. Check for memory leaks, M2 efficiency, and thread safety."
        }
    }
}
