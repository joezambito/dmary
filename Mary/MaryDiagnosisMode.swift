//
//  MaryDiagnosisMode.swift
//  Mary
//
//  Created by Joe Zambito on 29/4/2026.
//

import Foundation
import SwiftUI

/// Defines the current operational focus of the Mary AI.
enum MaryDiagnosisMode: String, CaseIterable, Identifiable {
    case chat           = "Chatting"
    case diagnose       = "Analyzing Code"
    case buildDiagnose  = "Compiler Check"
    case fixPlan        = "Generating Patch"

    var id: String { rawValue }

    /// The visual cue for the UI status bar.
    var statusColor: Color {
        switch self {
        case .chat: return .blue
        case .diagnose: return .orange
        case .buildDiagnose: return .purple
        case .fixPlan: return .green
        }
    }

    /// Determines if the UI should show a "Stop" button for heavy M2 tasks.
    var isInterruptible: Bool {
        switch self {
        case .chat: return false
        default: return true
        }
    }
    
    /// Descriptive hint for the "Thought Stream" header.
    var activityDescription: String {
        switch self {
        case .chat: return "Mary is listening..."
        case .diagnose: return "Mary is scanning for logic flaws..."
        case .buildDiagnose: return "Mary is running xcodebuild..."
        case .fixPlan: return "Mary is drafting a surgical fix..."
        }
    }
}
