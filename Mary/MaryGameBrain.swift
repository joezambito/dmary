//
//  MaryGameBrain.swift
//  Mary
//
//  Created by Joe Zambito on 27/4/2026.
//

import Foundation

/// This is a quiet sensor. It contains ZERO rules.
/// Renamed to MaryGameStatus to prevent conflict with other Enums.
enum MaryGameStatus {
    case none
    case gameThinking
}

struct MaryGameBrain {

    /// This ONLY detects the topic so the Main Brain knows what's happening.
    static func detect(_ message: String) -> MaryGameStatus {
        let lower = message.lowercased()
        
        let signals = [
            "game", "spritekit", "scenekit", "realitykit", 
            "game assets", "game play", "2d game", "3d game"
        ]
        
        return signals.contains { lower.contains($0) } ? .gameThinking : .none
    }

    /// This now returns an empty string. 
    /// All 'Smart' game rules must now be placed in your Main MaryBrain file.
    static func promptAddition(for status: MaryGameStatus) -> String {
        return ""
    }
}
