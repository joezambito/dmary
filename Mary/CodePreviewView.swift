//
//  CodePreviewView.swift
//  Mary
//
//  Created by Joe Zambito on 25/4/2026.
//

import SwiftUI
import AppKit

/// CLEANED: A high-density code preview station.
/// Optimized for the M2 Pro to provide instant visual verification of "Evidence."
struct CodePreviewView: View {
    let fileName: String
    let content: String
    var onClose: (() -> Void)?
    var onSendToMary: ((String) -> Void)?

    @State private var showCopiedToast = false
    @State private var showConfirmSend = false

    // 🏎️ Token Safety: 5000 chars is the "Sweet Spot" for M2 local inference.
    private var isTooLarge: Bool { content.count > 5000 }

    var body: some View {
        VStack(spacing: 0) {
            // Header: Status and Controls
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(fileName)
                        .font(.system(.subheadline, design: .monospaced).bold())
                    
                    if isTooLarge {
                        Label("Large Context Warning", systemImage: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.yellow)
                    }
                }

                Spacer()

                HStack(spacing: 12) {
                    Button(action: copyToClipboard) {
                        Image(systemName: showCopiedToast ? "checkmark" : "doc.on.doc")
                            .foregroundStyle(showCopiedToast ? .green : .primary)
                    }
                    .buttonStyle(.plain)
                    .help("Copy Content")

                    Button(action: { onClose?() }) {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.plain)
                    .help("Close Preview")
                }
            }
            .padding(16)
            .background(MaryTheme.panelBackground)

            Divider()

            // Code Display: Using a passive text container
            ScrollView {
                Text(content)
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                    .foregroundStyle(MaryTheme.mainText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
            }
            .background(Color(NSColor.textBackgroundColor))
            .textSelection(.enabled)

            Divider()

            // Action Footer
            HStack {
                Spacer()
                
                Button("Cancel", role: .cancel) { onClose?() }
                
                Button {
                    showConfirmSend = true
                } label: {
                    Text(isTooLarge ? "Send Anyway" : "Send to Mary")
                }
                .buttonStyle(.borderedProminent)
                .tint(isTooLarge ? .orange : .accentColor)
                .disabled(content.isEmpty)
            }
            .padding(16)
            .background(MaryTheme.panelBackground)
        }
        .frame(minWidth: 500, minHeight: 400)
        .confirmationDialog(
            "Send Evidence?",
            isPresented: $showConfirmSend,
            titleVisibility: .visible
        ) {
            Button("Confirm Send") {
                onSendToMary?(content)
                onClose?()
            }
        } message: {
            Text(isTooLarge 
                 ? "This file is over 5,000 characters. Mary might slow down while processing this much context." 
                 : "Send this file as technical evidence for the current session?")
        }
    }

    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)
        withAnimation { showCopiedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { showCopiedToast = false }
        }
    }
}
