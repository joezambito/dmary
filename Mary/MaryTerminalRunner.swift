//
//  MaryTerminalRunner.swift
//  Mary
//
//  Created by Joe Zambito on 28/4/2026.
//

import Foundation

/// A high-performance, non-blocking bridge to the macOS ZSH shell.
final class MaryTerminalRunner {
    
    struct TerminalResult {
        let output: String
        let errorLog: String
        let isSuccess: Bool
    }
    
    /// Executes a command with a mandatory timeout to prevent app hangs.
    func run(_ command: String, timeout: Double = 15.0) async -> TerminalResult {
        return await Task.detached(priority: .userInitiated) {
            let process = Process()
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            
            process.executableURL = URL(fileURLWithPath: "/bin/zsh")
            process.arguments = ["-c", command]
            process.standardOutput = outputPipe
            process.standardError = errorPipe
            
            do {
                try process.run()
                
                // 🛑 SAFETY: Kill the process if it takes too long
                let result = Self.waitForProcess(process, timeout: timeout)
                
                if !result {
                    process.terminate()
                    return TerminalResult(output: "", errorLog: "Execution Timed Out.", isSuccess: false)
                }
                
                let outputData = try outputPipe.fileHandleForReading.readToEnd() ?? Data()
                let errorData = try errorPipe.fileHandleForReading.readToEnd() ?? Data()
                
                return TerminalResult(
                    output: String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                    errorLog: String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
                    isSuccess: process.terminationStatus == 0
                )
            } catch {
                return TerminalResult(output: "", errorLog: "Process Error: \(error.localizedDescription)", isSuccess: false)
            }
        }.value
    }
    
    private static func waitForProcess(_ process: Process, timeout: Double) -> Bool {
        let start = Date()
        while process.isRunning {
            if Date().timeIntervalSince(start) > timeout { return false }
            Thread.sleep(forTimeInterval: 0.1)
        }
        return true
    }
}
