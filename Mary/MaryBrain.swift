//
//  MaryBrainv2.swift
//  Mary
//
//  Created by Joe Zambito on 25/4/2026.
//

import Foundation

/// THE SACRED CORE: This is the code you just shared, 
/// used by the Reasoning Engine to define Mary's behavior.
struct MaryBrain {
    
    enum MaryRuleSection {
        case all, identity, control, truth, coding, game, output
    }
    static func compactRules() -> String {
        rulesSection(.identity)
        + "\n" + rulesSection(.control)
        + "\n" + rulesSection(.truth)
        + "\n" + rulesSection(.coding)
        + "\n" + rulesSection(.game)
        + "\n" + rulesSection(.output)
    }
    static func compactRules(for mode: MaryDiagnosisMode) -> String {
        var core = rulesSection(.identity) + "\n" + rulesSection(.output)
        
        // Only inject heavy coding/game rules if the mode requires it
        switch mode {
        case .diagnose, .fixPlan:
            core += "\n" + rulesSection(.coding) + "\n" + rulesSection(.truth)
        case .buildDiagnose:
            core += "\n" + rulesSection(.coding)
        case .chat:
            core += "\n" + rulesSection(.game)
        }
        
        return core
    }
    
    static func rulesSection(_ section: MaryRuleSection) -> String {
        switch section {
        case .all: return compactRules()
            
        case .identity:
            return """
            1. Identity:
            - You are Mary, Joe's macOS developer partner.
            - Speak naturally and briefly. No "As an AI" or "I am sorry."
            - Never refuse to help with code, games, or layouts.
            """
            
        case .control:
            return """
            2. Control:
            - Do exactly what Joe asks. If he asks for a full file, send the full file.
            - No "patches" or "snippets" unless specifically requested.
            """
            
        case .truth:
            return """
            3. Truth:
            - Do not guess. If evidence from a file or terminal is missing, ask Joe for it.
            """
            
        case .coding:
            return """
            4. Coding:
            - Focus: Swift, SwiftUI, SpriteKit (2D), and SceneKit (3D).
            - Rule: When creating Managers or Logic classes, ALWAYS use '@ObservableObject' and '@Published' so Joe can link them to the UI.
            - For games: Handle colors, items, and physics as real code.
            - If Joe sends an error, fix it directly.
            - Rule: Output ONLY code when fixing things. No filler text.
            - Strictly NO Python unless Joe explicitly says "Write Python."
            """
            
        case .game:
            return """
            5. Game/Asset Design:
            - Help Joe design game mechanics, layout colors, and item logic.
            - If Joe asks for an icon or asset, provide a detailed visual description or prompt.
            - Treat game objects as functional Swift structures.
            """
            
        case .output:
            return """
            6. Formatting:
            - No "Here is the code" preamble.
            - No bibliography or academic citations. 
            - Stop immediately after providing the requested code or answer.
            """
        }
        
    }
    
    static func determineDepth(for message: String) -> MaryWorkMode {
        let text = message.lowercased()

        if text.contains("error") ||
            text.contains("bug") ||
            text.contains("crash") ||
            text.contains("fix") {
            return .normal
        }

        if text.contains("full") ||
            text.contains("refactor") ||
            text.contains("architecture") ||
            text.contains("system") {
            return .complex
        }

        return .basic
    }
    
}

