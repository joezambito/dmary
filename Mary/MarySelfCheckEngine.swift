//
//  MarySelfCheckEngine.swift
//  Mary
//
//  Created by Joe Zambito on 26/4/2026.
//

//
//  MarySelfCheckEngine.swift
//  Mary
//

import Foundation

/// CLEANED: A passive quality auditor.
/// It no longer has the power to force 'RETRY' loops or block the Brain.
struct MarySelfCheckEngine {
    
    /// Audits the answer for consistency.
    /// Returns a list of identified issues rather than blocking the output.
    static func performAudit(on answer: String) -> [String] {
        let lower = answer.lowercased()
        var issues: [String] = []
        
        if lower.contains("'''python") || lower.contains("def ") {
            issues.append("Detected non-Swift code block.")
        }
        
        if lower.contains("as an ai assistant") || lower.contains("language model") {
            issues.append("Detected AI persona leak.")
        }
        
        if lower.contains("thesis statement") {
            issues.append("Detected academic tone.")
        }
        
        return issues
    }
}
