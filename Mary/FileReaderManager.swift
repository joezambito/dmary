//
//  FileReaderManager.swift
//  Mary
//
//  Created by Joe Zambito on 25/4/2026.
//

import Foundation
import UniformTypeIdentifiers

/// THE INGESTION ENGINE: Optimized for high-speed file reading and safety.
final class FileReaderManager {
    static let shared = FileReaderManager()
    private init() {}

    /// Reads text with a focus on performance and Sandbox compliance.
    func readTextFile(at url: URL, maxCharacters: Int? = nil) -> String? {
        // 1. Mandatory Sandbox Access
        let access = url.startAccessingSecurityScopedResource()
        defer { if access { url.stopAccessingSecurityScopedResource() } }

        do {
            // 2. High-speed data loading (Mapped if possible for large files)
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            
            // 3. Decoding Strategy
            var content: String?
            if let utf8 = String(data: data, encoding: .utf8) {
                content = utf8
            } else if let utf16 = String(data: data, encoding: .utf16) {
                content = utf16
            } else {
                content = String(decoding: data, as: UTF8.self)
            }

            guard let finalContent = content else { return nil }

            // 4. Smart Truncation
            if let max = maxCharacters, finalContent.count > max {
                let prefix = String(finalContent.prefix(max))
                return """
                \(prefix)
                
                ---
                [TRUNCATED: File too large (\(finalContent.count) chars). Only showing first \(max).]
                ---
                """
            }

            return finalContent
            
        } catch {
            LogManager.shared.append("FileReaderManager Error: \(error.localizedDescription)")
            return nil
        }
    }
}
