//
//  MaryGameTemplates.swift
//  Mary
//
//  Created by Joe Zambito on 27/4/2026.
//

import Foundation

/// Just a list of categories. No rules.
enum MaryGameTemplateType { 
    case twoDStarter
    case threeDStarter
    case soundHelper
    case assetPlan 
}

struct MaryGameTemplates {
    
    /// CLEANED: This no longer gives Mary instructions.
    /// It only provides a 'Label' so the Main Brain knows which mode is active.
    static func getTemplateLabel(for type: MaryGameTemplateType) -> String {
        switch type {
        case .twoDStarter:  return "[Template: 2D Starter]"
        case .threeDStarter: return "[Template: 3D Starter]"
        case .soundHelper:   return "[Template: Audio Logic]"
        case .assetPlan:     return "[Template: Asset Organization]"
        }
    }
    
    // All behavior rules like "Smallest next step" or "Swift only" 
    // have been deleted from here and moved to your Main Brain.
}
