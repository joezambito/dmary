//
//  MaryRuleEnforcer.swift
//  Mary
//
//  Created by Joe Zambito on 26/4/2026.
//

import Foundation

/// Defines the result of a rule check.
/// Cleaned: Now just a report, not an executive command.
enum MaryRuleAction {
    case compliant
    case violation(String)
}

struct MaryRuleEnforcer {
    
    /// CLEANED: This now just audits the text. 
    /// The Main Brain decides whether to 'Retry' or just show the message.
    static func audit(reply: String) -> MaryRuleAction {
        let lower = reply.lowercased()
        
        // Audit for Apologies
        if lower.contains("i apologize") || lower.contains("i'm sorry") {
            return .violation("Apology detected.")
        }
        
        // Audit for Python leak (Unless requested)
        if lower.contains("```python") {
            return .violation("Python code block detected.")
        }
        
        // Audit for Empty Content
        if reply.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .violation("Empty content.")
        }

        return .compliant
    }
}
