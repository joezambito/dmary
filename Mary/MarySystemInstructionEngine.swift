//
//  MarySystemInstructionEngine.swift
//  Mary
//
//  Created by Joe Zambito on 29/4/2026.
//
import Foundation

/// CLEANED: This is now a Passive Configuration file.
/// It no longer generates sentences; it only provides metadata for the Brain.
struct MarySystemInstructionEngine {

    /// Returns a simple keyword pair that the Main Brain 
    /// will inject into its existing 'Directive' context.
    static func getMetadata(taskType: String, depth: String) -> String {
        // Return a lightweight string that adds context without redefining the personality.
        return "MODE: \(taskType) | DEPTH: \(depth)"
    }
}
