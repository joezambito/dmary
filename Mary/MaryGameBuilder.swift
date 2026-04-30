//
//  UMaryGameBuilder.swift
//  Mary
//
//  Created by Joe Zambito on 27/4/2026.
//

import Foundation

/// Just a definition. No rules.
enum MaryGameDimension { 
    case twoD
    case threeD 
}

/// A simple data container. 
/// The Main Brain will decide if/when to use this.
struct MaryGameObject {
    let name: String
    let role: String
    let shape: String
    let movement: String
}

struct MaryGameBuilder {
    
    /// CLEANED: This no longer 'Builds' a prompt block.
    /// It simply returns the data so the Main Brain can decide the 'Plan'.
    static func getGameContext(dimension: MaryGameDimension) -> String {
        // We return a simple tag. 
        // The Main Brain will see this and apply its OWN 'Smart' rules.
        return dimension == .twoD ? "[Context: 2D Environment]" : "[Context: 3D Environment]"
    }
    
    /// CLEANED: Removed the 'detectObjects' logic that was inventing assets.
    /// Mary should only talk about objects Joe specifically mentions.
}
