//
//  MaryFixPlanEngine.swift
//  Mary
//
//  Created by Joe Zambito on 29/4/2026.
//

import Foundation

/// THE CHIEF ENGINEER: Converts a raw diagnosis into a surgical repair strategy.
enum MaryFixPlanEngine {
    
    static func buildFixPlanPrompt(from diagnosis: String) -> String {
        """
        [PLAN_STATION_ALPHA]
        [TASK: SOURCE_CODE_REPAIR]
        
        ### 1. DIAGNOSTIC DATA
        \(diagnosis)

        ### 2. EXECUTION CONSTRAINTS
        - LANGUAGE: Swift 6 / SwiftUI
        - CONCURRENCY: Ensure @MainActor or Task usage where appropriate.
        - STYLE: Minimalist. Only change what is broken.
        - FORBIDDEN: Do not explain the fix. Do not provide a summary.

        ### 3. OUTPUT PROTOCOL
        1. Identify the 'Target File' name.
        2. Provide the corrected Swift code block.
        3. Ensure the code is self-contained or explicitly references existing Joe-project types.

        REPAIR START:
        """
    }
}
