//
//  MaryAgentLoop.swift
//  Mary
//

//
//  MaryAgentLoop.swift
//  Mary
//

import Foundation
import SwiftUI
import Combine
@MainActor
class MaryAgentLoop: ObservableObject {
    @Published var currentMode: MaryWorkMode = .normal
    @Published var activeSection: MaryDashboardSection = .chat
    @Published var history: [MaryChatMessage] = []
    
    func switchMode(_ newMode: MaryWorkMode) {
        self.currentMode = newMode
    }
    
    func addMessage(text: String, isUser: Bool) {
        let newMessage = MaryChatMessage(text: text, isUser: isUser)
        history.append(newMessage)
    }
}
