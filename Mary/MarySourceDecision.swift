//
//  MarySourceDecisionEngine.swift
//  Mary
//

import Foundation

/// CLEANED: This is now a Passive Utility.
/// It no longer 'Decides' the source; the Main Brain does that.
struct MarySourceDecisionEngine {

    /// CLEANED: This provides a 'hint' to the Brain, but does not force a choice.
    /// The Brain can override this if it detects deeper intent.
    static func getSuggestedSource(for message: String) -> MarySource {
        // Keep it simple: Short messages default to Brain Only to save M2 power.
        if message.count < 15 {
            return .brainOnly
        }
        
        // Otherwise, allow the Brain to access Evidence by default.
        return .evidenceAndBrain
    }
}
