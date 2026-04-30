//
//  MaryDiagnosticEngine.swift
//  Mary
//
//  Created by Joe Zambito on 29/4/2026.
//

import Foundation

/// THE EYES: Scans terminal logs to pinpoint the exact location and nature of failures.
class MaryDiagnosticEngine {
    
    struct CodeFix {
        let filePath: String?        // Track which file actually broke
        let lineNumber: Int?         // Track where it broke
        let originalError: String
        let suggestedSolution: String
        let needsResearch: Bool
    }
    
    /// Analyzes logs using advanced pattern matching for the Swift Compiler and macOS.
    func analyze(errorLog: String) async -> CodeFix {
        let line = mapErrorToLine(errorLog: errorLog)
        let path = mapFilePath(errorLog: errorLog)
        
        // 🚀 High-Speed Heuristics
        if errorLog.contains("permission denied") {
            return CodeFix(filePath: path, lineNumber: line, originalError: errorLog, 
                           suggestedSolution: "Terminal access blocked. Try: 'chmod +x' on the target file.", needsResearch: false)
        }
        
        if errorLog.contains("value of optional type") && errorLog.contains("must be unwrapped") {
            return CodeFix(filePath: path, lineNumber: line, originalError: errorLog, 
                           suggestedSolution: "Swift safely requires unwrapping. Use 'if let' or '??' default value.", needsResearch: false)
        }
        
        if errorLog.contains("connection refused") {
            return CodeFix(filePath: path, lineNumber: line, originalError: errorLog, 
                           suggestedSolution: "Local port 8082 is unreachable. Is the TWS/API server running?", needsResearch: true)
        }

        // 🧠 Fallback to Deep Reasoning
        return CodeFix(
            filePath: path,
            lineNumber: line,
            originalError: errorLog,
            suggestedSolution: "Analyzing complex logic error...",
            needsResearch: true
        )
    }
    
    /// Extracts the line number from: /Path/To/File.swift:42:10
    func mapErrorToLine(errorLog: String) -> Int? {
        let pattern = #":(\d+):"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: errorLog, range: NSRange(errorLog.startIndex..., in: errorLog)),
              let range = Range(match.range(at: 1), in: errorLog) else { return nil }
        
        return Int(errorLog[range])
    }
    
    /// Extracts the file path to help the CodeWriter find the file automatically.
    func mapFilePath(errorLog: String) -> String? {
        // Looks for absolute paths ending in .swift
        let pattern = #"(/[^\s]+.swift)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: errorLog, range: NSRange(errorLog.startIndex..., in: errorLog)),
              let range = Range(match.range(at: 1), in: errorLog) else { return nil }
        
        return String(errorLog[range])
    }
}
