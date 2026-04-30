//
//  MaryErrorReader.swift
//  Mary
//
//  Created by Joe Zambito on 27/4/2026.
//

import Foundation
/*
PAUSED DEBUG ONLY - missing support types/// THE LOGIC FILTER: Distills raw logs into a collection of specific source-code failures.
enum MaryErrorReader {
    
    /// Parses build output into structured issues.
    static func read(_ text: String) -> [MaryErrorIssue] {
        let lines = text.components(separatedBy: .newlines)
        var issues: [MaryErrorIssue] = []

        for line in lines {
            let lower = line.lowercased()
            // Catch errors, failures, and common Swift syntax "Expected" messages
            if lower.contains("error:") || lower.contains("fail") || lower.contains("expected") {
                issues.append(MaryErrorIssue(
                    file: extractFile(from: line),
                    line: extractLineNumber(from: line),
                    message: cleanErrorMessage(from: line)
                ))
            }
        }
        return issues
    }

    /// Generates the concise block used in the MaryReasoningEngine prompt.
    static func promptBlock(from text: String) -> String {
        let issues = read(text)
        guard !issues.isEmpty else { return "Build successful or no clear errors detected." }

        // M2 Pro Tip: Limit to top 5 errors to prevent context overflow in deep builds.
        let topIssues = issues.prefix(5)
        return "CRITICAL ERRORS DETECTED:\n" + topIssues.map {
            "📍 [\($0.file ?? "Global")] Line \($0.line ?? 0): \($0.message)"
        }.joined(separator: "\n")
    }

    private static func extractFile(from line: String) -> String? {
        // Splitting by colon handles the standard "Path/To/File.swift:Line:Col: error:"
        let parts = line.components(separatedBy: ":")
        return parts.first(where: { $0.hasSuffix(".swift") })?
                    .components(separatedBy: "/").last
    }

    private static func extractLineNumber(from line: String) -> Int? {
        let parts = line.components(separatedBy: ":")
        // In Swift compiler logs, the line number is usually the element immediately 
        // following the file path (e.g., [File.swift, "42", "10", "error..."])
        if let swiftIndex = parts.firstIndex(where: { $0.hasSuffix(".swift") }),
           parts.indices.contains(swiftIndex + 1) {
            return Int(parts[swiftIndex + 1].trimmingCharacters(in: .whitespaces))
        }
        return nil
    }
    
    private static func cleanErrorMessage(from line: String) -> String {
        // Removes the path and line data to keep the message focused
        if let errorRange = line.range(of: "error: ", options: .caseInsensitive) {
            return String(line[errorRange.upperBound...]).trimmingCharacters(in: .whitespaces)
        }
        return line.trimmingCharacters(in: .whitespaces)
    }
}
 */

