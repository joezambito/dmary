//
//  MarySoundBuilder.swift
//  Mary
//
//  Created by Joe Zambito on 27/4/2026.
//

import Foundation

/// Defines the sound categories.
enum MarySoundType: String, Codable { 
    case effect, music 
}

/// A simple data model for a sound asset.
struct MarySoundItem: Identifiable, Codable {
    let id = UUID()
    let name: String
    let fileName: String
    let type: MarySoundType
    let purpose: String
}

/// CLEANED: A passive data provider.
/// It provides raw information about available sounds but does not write code.
struct MarySoundBuilder {
    
    /// CLEANED: Returns raw sound data. 
    /// The Main Brain decides how to format this into its 'Plan'.
    static func getAvailableSounds() -> [MarySoundItem] {
        // This would eventually pull from your project's Actual Assets folder.
        return [] 
    }
    
    // REMOVED: spriteKitCode(file:) 
    // The Brain will generate its own SKAction or AVAudioPlayer code.
}
