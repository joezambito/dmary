//
//  UniformTypeIdentifiers.swift
//  Mary
//
//  Created by Joe Zambito on 25/4/2026.
//

//
//  UniformTypeIdentifiers.swift
//  Mary
//

import UniformTypeIdentifiers

extension UTType {
    /// The official export type for Mary Chat Sessions.
    /// Ensure 'com.joezambito.mary.chat' is added to Info.plist under 'Exported Type Identifiers'.
    static let maryChatExport = UTType(exportedAs: "com.joezambito.mary.chat", conformingTo: .json)
    
    /// A helper to check for Mary-compatible files.
    static var maryCompatibleTypes: [UTType] {
        [.maryChatExport, .swiftSource, .text, .json]
    }
}
