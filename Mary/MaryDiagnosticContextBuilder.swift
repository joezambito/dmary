//
//  MaryDiagnosticContextBuilder.swift
//  Mary
//
//  Created by Joe Zambito on 29/4/2026.
//
import Foundation

/// THE PROSECUTOR: Compiles all technical evidence into a high-rigidity prompt.
enum MaryDiagnosticContextBuilder {
    /*
     PAUSED DEBUG ONLY - missing support types
     static func build(
     userMessage: String,
     attachedText: String,
     projectSnapshot: MaryProjectSnapshot?,
     diagnosticResult: MaryDiagnosticResult
     ) -> String {
     
     let snapshotSummary = projectSnapshot?.summary ?? "Scope restricted to active file only."
     
     return """
     [MODE: DIAGNOSTIC_ENGINE_ALPHA]
     [TARGET: SOURCE_REPAIR]
     
     ### 1. USER INTENT
     "\(userMessage)"
     
     ### 2. COMPILER/RUNTIME EVIDENCE
     \(diagnosticResult.promptBlock)
     
     ### 3. ATTACHED CONTEXT (CODE)
     \(attachedText)
     
     ### 4. PROJECT ARCHITECTURE
     \(snapshotSummary)
     
     ### 5. EXECUTION PROTOCOL
     1. Identify the line(s) causing the failure in section 2.
     2. Analyze section 3 for logic or syntax conflicts.
     3. Provide a 'Surgical Patch' or 'Full File Replacement'.
     4. CRITICAL: Use Swift 6 / Concurrency-safe patterns if applicable.
     5. OUTPUT: Return only the corrected code block. No conversational filler.
     """
     }
     }
     
     */
}
