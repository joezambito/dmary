//
//  ChatViewModel.swift
//  Mary
//

import Foundation
import Combine
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [MaryChatMessage] = []
    @Published var input: String = ""
    @Published var isThinking: Bool = false
    @Published var thinkingText: String = "Mary is analyzing..."
    @Published var attachedFiles: [URL] = []

    func send() {
        guard !input.isEmpty else { return }
        let newMsg = MaryChatMessage(text: input, isUser: true)
        messages.append(newMsg)
        input = ""

        // Add your logic to trigger Mary's response here
    }

    func sendMessage() {
        send()
    }

    func clearChat() {
        messages.removeAll()
        attachedFiles.removeAll()
    }
}
