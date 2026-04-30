//
//  MaryTaskBrain.swift
//  Mary
//
//  Created by Joe Zambito on 26/4/2026.
//

import Foundation

/// CLEANED: A passive intent parser.
/// It provides hints to the Main Brain but never blocks or forces a decision.
struct MaryTaskBrain {

    func parseIntent(for message: String) -> MaryTaskDecision {
        let text = message.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = text.lowercased()

        // Simplify: Just provide a basic categorization based on length and core action.
        // The Main Brain will perform the actual 'Reasoning Protocol'.
        
        if lower.contains("hi mary this is joe") {
            return decision(.conversation, control: .activateJoe, reason: "Greeting")
        }
        
        if lower.contains("done mary") {
            return decision(.conversation, control: .deactivateJoe, reason: "Session end")
        }

        // Suggested Mode Hint
        let suggestedMode: MaryTaskMode = (lower.count > 20) ? .writeCode : .conversation

        return decision(suggestedMode, reason: "Heuristic hint based on message length.")
    }

    private func decision(_ mode: MaryTaskMode, control: MaryControlAction = .none, reason: String) -> MaryTaskDecision {
        MaryTaskDecision(
            mode: mode,
            reason: reason,
            control: control
        )
    }
}

enum MaryTaskMode {
    case conversation, diagnoseProblem, investigateSetup, writeCode, researchInternet
}

enum MaryControlAction {
    case none, activateJoe, deactivateJoe
}

struct MaryTaskDecision {
    let mode: MaryTaskMode
    let reason: String
    let control: MaryControlAction
}
