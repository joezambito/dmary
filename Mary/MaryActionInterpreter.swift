//
//  MaryActionInterpreter.swift
//  Mary
//
//  Created by Joe Zambito on 27/4/2026.
//

import Foundation

/// THE SWITCHBOARD: Detects Joe's intent and primes the Reasoning Engine.
enum MaryUserAction {
    case normal
    case diagnose
    case writeCode
    case gameDev
    case assetDesign
}

enum MaryActionInterpreter {

    /// Detects the primary intent with a priority-based fallback system.
    static func detect(_ message: String) -> MaryUserAction {
        let input = message.lowercased()
        
        // Priority 1: Crisis Management (Diagnosis)
        let diagKeys = ["fix", "error", "bug", "broken", "crash", "fails", "issue"]
        if diagKeys.contains(where: input.contains) { return .diagnose }
        
        // Priority 2: Creative Mechanics (Game Dev)
        let gameKeys = ["game", "sprite", "scene", "physics", "collision", "node"]
        if gameKeys.contains(where: input.contains) { return .gameDev }

        // Priority 3: Visual/UI (Asset Design)
        let uiKeys = ["layout", "color", "icon", "asset", "padding", "view", "ui"]
        if uiKeys.contains(where: input.contains) { return .assetDesign }
        
        // Priority 4: Production (Code Generation)
        let codeKeys = ["write", "create", "swift", "func", "class", "struct", "logic"]
        if codeKeys.contains(where: input.contains) { return .writeCode }
        
        return .normal
    }

    /// Generates a specific System Directive to focus the LLM's reasoning.
    static func promptBlock(for action: MaryUserAction) -> String {
        switch action {
        case .diagnose:
            return "[MISSION: DIAGNOSTIC] Analyze logs and code provided. Identify the root cause. Provide the definitive fix in a single Swift block."
        case .gameDev:
            return "[MISSION: GAME ARCHITECTURE] Focus on state management, physics interactions, and frame-rate optimization."
        case .assetDesign:
            return "[MISSION: DESIGNER] Prioritize SwiftUI aesthetics, Human Interface Guidelines (HIG), and visual consistency."
        case .writeCode:
            return "[MISSION: ARCHITECT] Generate production-ready, modular Swift code. Use clean architecture and include comments."
        case .normal:
            return ""
        }
    }
}
