//
//  MaryJudgementEngine.swift
//  Mary
//
//  Created by Joe Zambito on 26/4/2026.
//

import Foundation

/// A simple structure to hold the Brain's decisions.
/// No logic or rules are stored here.
struct MaryJudgement {
    let opinion: String
    let confidence: Double
    let bestNextAction: String
    let warning: String?
}

struct MaryJudgementEngine {

    /// CLEANED: This now just packages data.
    /// It does not invent opinions or rules like 'No apologies'.
    static func createJudgement(
        opinion: String,
        confidence: Double,
        nextAction: String,
        warning: String? = nil
    ) -> MaryJudgement {
        
        return MaryJudgement(
            opinion: opinion,
            confidence: confidence,
            bestNextAction: nextAction,
            warning: warning
        )
    }
    
    /// This file no longer 'judges' Joe's text. 
    /// The Main Brain performs the logic and uses this file to store the result.
}
