//
//  LogManager.swift
//  Mary
//
//  Created by Joe Zambito on 25/4/2026.
//

import Foundation

/// THE FLIGHT RECORDER: Thread-safe, performance-optimized logging.
final class LogManager {
    static let shared = LogManager()
    
    // Performance: Reusing the formatter saves CPU cycles on the M2
    private static let formatter = ISO8601DateFormatter()
    
    private let queue = DispatchQueue(label: "com.mary.LogManager", qos: .utility)
    private var buffer: [String] = []
    
    // Safety: Prevent the log from eating RAM during infinite loops
    private let maxLogLines = 1000

    private init() {}

    /// Appends a message with a timestamp. Thread-safe and non-blocking.
    func append(_ message: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let ts = Self.formatter.string(from: Date())
            let line = "[\(ts)] \(message)"
            
            self.buffer.append(line)
            
            // Maintain a rolling window of logs
            if self.buffer.count > self.maxLogLines {
                self.buffer.removeFirst(100)
            }
            
            #if DEBUG
            print(line)
            #endif
        }
    }

    /// Retrieves the full log history safely.
    func readAll() -> String {
        queue.sync {
            buffer.joined(separator: "\n")
        }
    }

    /// Purges the flight recorder.
    func clear() {
        queue.async {
            self.buffer.removeAll()
        }
    }
}
