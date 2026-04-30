//
//  ChatBubble.swift
//  Mary
//
//  Created by Joe Zambito on 25/4/2026.
//

import SwiftUI
import AppKit

struct ChatBubble: View {
    let text: String
    let isUser: Bool

    private var sender: String? {
        if let idx = text.firstIndex(of: ":") {
            return String(text[..<idx])
        }
        return nil
    }

    private var bodyText: String {
        let validPrefixes = ["You:", "Mary:", "Joe:"]
        for prefix in validPrefixes {
            if text.hasPrefix(prefix) {
                if let idx = text.firstIndex(of: ":") {
                    let after = text.index(after: idx)
                    return String(text[after...]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        return text
    }

    private var fontDesign: Font.Design {
        return text.contains("{") || text.contains("func") || text.contains("let ") ? .monospaced : .default
    }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 20) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                if let sender = sender {
                    Text(sender)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(bodyText)
                    .font(.system(.body, design: fontDesign))
                    .padding(12)
                    .background(isUser ? Color.accentColor : Color(NSColor.controlBackgroundColor))
                    .foregroundColor(isUser ? .white : .primary)
                    .cornerRadius(16)
                    .textSelection(.enabled)
            }

            if !isUser { Spacer(minLength: 20) }
        }
        .padding(.horizontal)
    }
}
