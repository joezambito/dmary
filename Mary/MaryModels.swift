//
//  MaryModels.swif
//  Mary
//
//  Created by Joe Zambito on 30/4/2026.
//

import SwiftUI
import Foundation

/// Represents a single turn in the conversation or a system log.
struct MaryChatMessage: Identifiable, Equatable, Codable {
    let id: UUID
    let timestamp: Date
    let text: String
    let isUser: Bool

    var roleName: String {
        isUser ? "Joe" : "Mary"
    }

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        text: String,
        isUser: Bool
    ) {
        self.id = id
        self.timestamp = timestamp
        self.text = text
        self.isUser = isUser
    }
}

/// Navigation sections for the Sidebar.
enum MaryDashboardSection: String, CaseIterable, Identifiable, Codable {
    case chat = "Chat"
    case library = "Library"
    case diagnostics = "Diagnostics"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .chat:
            return "terminal.fill"
        case .library:
            return "folder.fill.badge.gearshape"
        case .diagnostics:
            return "waveform.path.ecg"
        }
    }
}

/// Cognitive depth levels for the local model.
/*
enum MaryWorkMode: String, CaseIterable, Identifiable {
    case basic = "Basic"
    case normal = "Normal"
    case complex = "Complex"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .basic: return "Fast & Direct"
        case .normal: return "Architectural Insight"
        case .complex: return "System-Wide Refactor"
        }
    }

    var themeColor: Color {
        switch self {
        case .basic: return .blue
        case .normal: return .green
        case .complex: return .purple
        }
    }
}
*/
