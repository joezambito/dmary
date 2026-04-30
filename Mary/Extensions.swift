//
//  Extensions.swift
//  Mary
//
//  Created by Joe Zambito on 25/4/2026.
//

//
//  Extensions.swift
//  Mary
//
//  Replacements for small helpers and cross-platform view modifiers.
//

import Foundation

extension FileManager {
    /// Returns the dedicated URL for app data storage.
    /// Optimized for M2 disk I/O by minimizing redundant system calls.
    static func appFolder(name: String = "Mary") -> URL? {
        // 1. Locate the base Application Support directory
        guard let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let appUrl = base.appendingPathComponent(name, isDirectory: true)
        
        // 2. Passive Creation: Only attempt creation if not already in memory/cache
        // Using 'path' check is faster for M2 SSDs than full URL attribute fetching
        if !FileManager.default.fileExists(atPath: appUrl.path) {
            do {
                try FileManager.default.createDirectory(at: appUrl, withIntermediateDirectories: true)
            } catch {
                return nil
            }
        }
        
        return appUrl
    }
}
