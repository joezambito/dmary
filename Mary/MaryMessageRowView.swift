import SwiftUI
import AppKit

struct MaryMessageRowView: View {
    let message: ChatMessage
    let onSaveGeneratedFile: (MaryGeneratedFile) -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.isUser { Spacer(minLength: 90) }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 7) {
                // 1. The Message Bubble
                // CLEANED: Using a standard font to speed up rendering during generation.
                Text(message.text)
                    .font(.system(size: 14, design: .monospaced))
                    .padding(12)
                    .background(message.isUser ? MaryTheme.accent : MaryTheme.panelBackground)
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(12)
                    // Note: .textSelection is removed here. 
                    // Use the 'Copy' button for large code blocks to keep the UI fast.
                
                // 2. Action Row
                if !message.isUser {
                    HStack(spacing: 12) {
                        Button {
                            copyToClipboard(message.text)
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                                .font(.caption2.weight(.bold))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)

                        ForEach(message.generatedFiles) { file in
                            Button {
                                onSaveGeneratedFile(file)
                            } label: {
                                Label("Save \(file.fileName)", systemImage: "arrow.down.doc")
                                    .font(.caption2.weight(.bold))
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.top, 2)
                }
            }
            .frame(maxWidth: 750, alignment: message.isUser ? .trailing : .leading)

            if !message.isUser { Spacer(minLength: 90) }
        }
        .padding(.vertical, 4)
    }

    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
