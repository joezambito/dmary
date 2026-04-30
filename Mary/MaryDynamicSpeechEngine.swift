//
//  MaryDynamicSpeechEngine.swift
//  Mary
//
//  Created by Joe Zambito on 29/4/2026.
//

import Foundation

/// THE VOICE BOX: Orchestrates the final prompt structure for the LLM.
struct MaryDynamicSpeechEngine {
    
    /// Pulls the 'Source of Truth' and adds temporary environmental awareness.
    static func generateSystemPrompt(currentFile: String? = nil) -> String {
        var rules = MaryBrain.compactRules()
        
        // 🏎️ M2 Optimization: If we have a file focus, inject it as a primary directive.
        if let file = currentFile {
            rules += "\nCURRENT_FOCUS: You are currently assisting Joe with the file '\(file)'."
        }
        
        return rules
    }
    
    /// Prepares the message, ensuring the System Rules are weighted heavily.
    static func prepareFinalPrompt(userMessage: String, currentFile: String? = nil) -> String {
        let systemRules = generateSystemPrompt(currentFile: currentFile)
        
        // Use XML-style tags; local LLMs (Llama/Mistral) parse these with higher accuracy.
        return """
        <system>
        \(systemRules)
        </system>

        <user>
        \(userMessage)
        </user>
        
        <assistant>
        """
    }
}
