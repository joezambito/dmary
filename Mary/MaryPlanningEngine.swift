import Foundation

/// A simple data container for the Brain's strategy.
/// No hard-coded steps or 'No Questions' rules allowed here.
struct MaryPlan {
    let steps: [String]
    let shouldAskQuestions: Bool
}

struct MaryPlanningEngine {

    /// CLEANED: This no longer 'makes' a plan using its own rules.
    /// It simply packages the strategy decided by the Main Brain.
    static func packagePlan(steps: [String], allowQuestions: Bool) -> MaryPlan {
        return MaryPlan(
            steps: steps,
            shouldAskQuestions: allowQuestions
        )
    }
    
    // The logic of "If needsCode then Output File" has been moved 
    // to the Main Brain's system prompt.
}
