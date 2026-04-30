//
//  MaryProjectScanner.swift
//  Mary
//
//  Created by Joe Zambito on 29/4/2026.
//

import Foundation

/// A raw data snapshot of the project structure.
/// No summaries or arbitrary caps allowed here.
struct MaryProjectSnapshot {
    let rootPath: String
    let swiftFiles: [URL]
    let projectFiles: [URL]
    let packageFiles: [URL]

    var summary: String {
        """
        Root: \(rootPath)
        Swift files: \(swiftFiles.count)
        Xcode projects/workspaces: \(projectFiles.count)
        Package files: \(packageFiles.count)
        """
    }
}

enum MaryProjectScanner {
    
    /// CLEANED: A raw scanner that gathers file information.
    /// Logic for 'skipping' or 'capping' is now managed by the Brain.
    static func scan(root: URL, skipping folders: [String] = []) -> MaryProjectSnapshot {
        let fileManager = FileManager.default
        var swiftPaths: [URL] = []
        var projectPaths: [URL] = []
        var packagePaths: [URL] = []
        
        let enumerator = fileManager.enumerator(
            at: root,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )
        
        while let fileURL = enumerator?.nextObject() as? URL {
            let path = fileURL.path
            
            // The Brain provides the skip list now.
            if folders.contains(where: { path.contains("/\($0)") }) {
                enumerator?.skipDescendants()
                continue
            }
            
            if path.hasSuffix(".swift") { swiftPaths.append(fileURL) }
            if path.hasSuffix(".xcodeproj") || path.hasSuffix(".xcworkspace") { projectPaths.append(fileURL) }
            if path.hasSuffix("Package.swift") { packagePaths.append(fileURL) }
        }
        
        return MaryProjectSnapshot(
            rootPath: root.lastPathComponent,
            swiftFiles: swiftPaths,
            projectFiles: projectPaths,
            packageFiles: packagePaths
        )
    }
}
