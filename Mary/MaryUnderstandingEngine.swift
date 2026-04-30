import Foundation

/// CLEANED: A passive metadata provider.
/// It no longer 'classifies' intent; it prepares the input for the Main Brain.
struct MaryUnderstandingEngine {
    
    /// Encapsulates the raw state of the user's request.
    struct Analysis {
        let rawInput: String
        let detectedKeywords: Set<String>
    }
    
    /// CLEANED: Simply extracts keywords without assigning 'Intent'.
    /// This keeps the M2 Pro fast by avoiding complex logical branching.
    func analyze(_ input: String) -> Analysis {
        let text = input.lowercased()
        
        // Just a simple collector of technical terms to help the Brain focus.
        let technicalTerms = ["tws", "api", "spritekit", "scenekit", "swiftui", "terminal"]
        let found = technicalTerms.filter { text.contains($0) }
        
        return Analysis(
            rawInput: input,
            detectedKeywords: Set(found)
        )
    }
    
    // REMOVED: requiresSearch logic. 
    // The Main Brain now decides this dynamically via its reasoning protocol.
}
