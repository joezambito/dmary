//
//  MaryChatModels.swift
//  Mary
//
//  Created by Joe Zambito on 29/4/2026.
//

import Foundation

/// THE ARTIFACT: A single file produced by Mary's reasoning engine.
struct MaryGeneratedFile: Identifiable, Equatable {
    let id = UUID()
    let fileName: String
    let content: String
    
    /// Utility for the MaryProjectManager to write this artifact to the M2 SSD.
    var data: Data? {
        content.data(using: .utf8)
    }
}

/// THE LOG: A single turn in the conversation, potentially carrying code artifacts.
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let generatedFiles: [MaryGeneratedFile]
    let timestamp: Date

    init(
        text: String,
        isUser: Bool,
        generatedFiles: [MaryGeneratedFile] = [],
        timestamp: Date = Date()
    ) {
        self.text = text
        self.isUser = isUser
        self.generatedFiles = generatedFiles
        self.timestamp = timestamp
    }
    
    /// Helper: Quick check if this message contains code artifacts.
    var hasArtifacts: Bool { !generatedFiles.isEmpty }
}
