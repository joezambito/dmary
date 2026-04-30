//
//  MaryImageGenerator.swift
//  Mary
//
//  Created by Joe Zambito on 27/4/2026.
//

import Foundation
import SwiftUI
import AppKit
import Combine 
/// CLEANED: This is now a Pure Tool.
/// It no longer 'optimizes' prompts or 'decides' to save memory.
class MaryImageGenerator: ObservableObject {
    private let realGenerator = MaryRealImageGenerator()
    
    @Published var lastGeneratedImage: NSImage?
    
    /// The Main Brain sends the FULL prompt. 
    /// This file just passes it to the hardware.
    func generateAsset(finalPrompt: String) async {
        // No more 'Designing...' prints or optimization logic here.
        if let image = await realGenerator.generate(prompt: finalPrompt) {
            DispatchQueue.main.async {
                self.lastGeneratedImage = image
            }
        }
    }
    
    /// CLEANED: AssetType is now just a simple list.
    /// The Main Brain handles the 'RawValue' naming.
    enum AssetType: String {
        case icon, texture, sprite, uiElement
    }
}
