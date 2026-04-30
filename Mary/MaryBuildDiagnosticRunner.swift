//
//  MaryBuildDiagnosticRunner.swift
//  Mary
//
//  Created by Joe Zambito on 29/4/2026.
//

import Foundation

/// THE FORENSICS LAB: Runs shell-level diagnostics to catch build errors.
enum MaryBuildDiagnosticRunner {
    /*
     PAUSED DEBUG ONLY - missing support types    /// Automatically detects project type and runs the appropriate build test.
     static func diagnoseProject(root: URL) async -> MaryDiagnosticResult {
     let snapshot = MaryProjectScanner.scan(root: root)
     let escapedPath = "\"\(root.path)\""
     
     // 🏎️ M2 Speed: Run the diagnostic in a detached task to prevent UI hitching
     return await Task.detached(priority: .userInitiated) {
     if !snapshot.packageFiles.isEmpty {
     return await MaryDiagnosticEngine.diagnose(
     command: "cd \(escapedPath) && swift build -Xswiftc -suppress-warnings 2>&1"
     )
     }
     
     if !snapshot.projectFiles.isEmpty {
     return await MaryDiagnosticEngine.diagnose(
     command: "cd \(escapedPath) && xcodebuild -quiet -list 2>&1"
     )
     }
     
     return MaryDiagnosticEngine.diagnoseText("""
     [SCAN FAILURE]: No buildable manifest found.
     ---
     Project Summary:
     \(snapshot.summary)
     """)
     }.value
     }
     /*
      PAUSED DEBUG ONLY - missing support types    /// Runs a custom command in a specific root, safely sanitized.
      static func runCustom(command: String, root: URL? = nil) async -> MaryDiagnosticResult {
      let prefix = root != nil ? "cd \"\(root!.path)\" && " : ""
      let fullCommand = "\(prefix)\(command) 2>&1"
      
      return await Task.detached(priority: .userInitiated) {
      await MaryDiagnosticEngine.diagnose(command: fullCommand)
      }.value
      }
      }
      
      }
      }
      */*/
}
