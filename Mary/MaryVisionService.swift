//
//  MaryVisionService.swift
//  Mary
//
//  Created by Joe Zambito on 30/4/2026.
//

import Foundation
import AppKit

/// CLEANED: A passive sensory bridge.
/// It handles the 'IO' of vision but never provides its own 'Logic' or 'Voice'.
final class MaryVisionService {
    private let terminal = MaryTerminalRunner()
    
    /// CLEANED: Returns the path to the capture if successful, or nil.
    func captureScreen(to path: String = "/tmp/mary_capture.png") async -> String? {
        // -x: silent mode
        // -i: interactive (optional, but keep it -x for automation)
        let command = "screencapture -x \(path)"
        let result = await terminal.run(command, timeout: 5.0)
        
        return result.isSuccess ? path : nil
    }
    
    /// CLEANED: Provides raw metadata about an image.
    /// The Main Brain performs the actual visual reasoning.
    func getImageMetadata(at url: URL) -> [String: String] {
        guard let image = NSImage(contentsOf: url) else { return [:] }
        
        return [
            "name": url.lastPathComponent,
            "width": "\(image.size.width)",
            "height": "\(image.size.height)"
        ]
    }
}
