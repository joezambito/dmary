//
//  MaryResearchService.swift
//  Mary
//

import Foundation

/// A simple structure to hold research data.
struct MaryResearchResult {
    let query: String
    let summary: String
    let sourceUsed: String
}

struct MaryResearchService {

    /// CLEANED: This is now a passive utility.
    /// It cleans strings for the Brain but does not invent 'Brain rules'.
    static func prepareResearch(
        userText: String,
        recentMessages: [String]
    ) -> MaryResearchResult {

        // Just provide the raw combined text. 
        // Let the Main Brain decide how to truncate or format it.
        let combined = ([userText] + recentMessages).joined(separator: "\n")
        
        let cleaned = combined
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return MaryResearchResult(
            query: cleaned,
            summary: cleaned, // Send raw data; Brain handles the 'Summary' logic.
            sourceUsed: "Local Project Context"
        )
    }
}
