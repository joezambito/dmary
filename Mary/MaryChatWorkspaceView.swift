import SwiftUI
import AppKit

struct MaryChatWorkspaceView: View {
    @EnvironmentObject var brain: MaryReasoningEngine
    @EnvironmentObject var settings: SettingsManager

    @State private var userInput: String = ""
    @State private var isProcessing: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("MARY'S SYSTEM LOGS", systemImage: "terminal")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)

                        Text(brain.thoughts)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .id("BottomLog")
                    }
                    .padding()
                }
                .background(Color(NSColor.textBackgroundColor).opacity(0.5))
                .onChange(of: brain.thoughts) { _ in
                    withAnimation { proxy.scrollTo("BottomLog", anchor: .bottom) }
                }
            }
            .frame(minHeight: 200)

            Divider()

            HStack(spacing: 12) {
                Button(action: openFilePicker) {
                    Image(systemName: "plus.viewfinder")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .help("Ingest code folder or asset")

                TextField("Ask Mary to build, fix, or design...", text: $userInput)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(sendMessage)
                    .disabled(isProcessing)

                if isProcessing {
                    ProgressView().controlSize(.small)
                } else {
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.return, modifiers: .command)
                }
            }
            .padding()

            statusFooter
        }
    }

    private func openFilePicker() {
        brain.thoughts += "\n> File picker requested."
    }

    private func sendMessage() {
        let trimmed = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard !isProcessing else { return }

        Task { @MainActor in
            isProcessing = true
            brain.currentMode = brain.analyzeComplexity(for: trimmed)
            brain.thoughts += "\n> Joe: \(trimmed)"
            userInput = ""
            isProcessing = false
        }
    }

    private var statusFooter: some View {
        HStack {
            Group {
                Text("MODE: \(brain.currentMode.rawValue.uppercased())")
                Separator()
                Text("HARDWARE: M2 PRO")
                Separator()
                Text("BACKEND: 8082")
            }
            .font(.system(size: 9, weight: .semibold, design: .monospaced))
            .foregroundColor(.secondary)

            Spacer()

            Button("Reset Environment") {
                brain.thoughts = "> Rebooting context..."
                brain.reset()
            }
            .buttonStyle(.link)
            .font(.caption2)
        }
        .padding([.horizontal, .bottom], 10)
    }
}

struct Separator: View {
    var body: some View {
        Text("|").foregroundColor(.gray).opacity(0.5)
    }
}
