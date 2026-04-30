import SwiftUI
import AppKit
import UniformTypeIdentifiers

enum MaryWorkspacePaneMode: String, CaseIterable, Identifiable {
    case chat = "Chat"
    case terminal = "Terminal"
    case both = "Both"

    var id: String { rawValue }
}

struct MaryChatWorkspaceView: View {
    @EnvironmentObject var brain: MaryReasoningEngine
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var control: MaryControlCenter

    @State private var userInput: String = ""
    @State private var isProcessing: Bool = false
    @State private var paneMode: MaryWorkspacePaneMode = .chat
    @State private var showThinkingPanel: Bool = true
    @State private var attachedFiles: [URL] = []

    var body: some View {
        VStack(spacing: 0) {
            topBar
            Divider()
            contentArea
            Divider()
            attachmentsRow
            composerArea
            statusFooter
        }
        .background(MaryTheme.appBackground)
        .onDrop(of: [UTType.fileURL.identifier], isTargeted: nil, perform: handleDrop)
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Picker("View", selection: $paneMode) {
                ForEach(MaryWorkspacePaneMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 220)

            Picker("Task", selection: $control.selectedTask) {
                ForEach(MaryControlCenter.TaskKind.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 360)

            Picker("Depth", selection: $control.selectedDepth) {
                ForEach(MaryControlCenter.Depth.allCases) { depth in
                    Text(depth.rawValue).tag(depth)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 240)

            Spacer()

            Button {
                showThinkingPanel.toggle()
            } label: {
                Label(showThinkingPanel ? "Hide Thinking" : "Show Thinking", systemImage: "brain.head.profile")
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var contentArea: some View {
        switch paneMode {
        case .chat:
            chatPane
        case .terminal:
            terminalPane
        case .both:
            HStack(spacing: 0) {
                chatPane
                Divider()
                terminalPane
            }
        }
    }

    private var chatPane: some View {
        VStack(spacing: 0) {
            if showThinkingPanel {
                thinkingPanel
                Divider()
            }

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("MARY CHAT / SYSTEM STREAM", systemImage: "message")
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
                .background(Color(NSColor.textBackgroundColor).opacity(0.45))
                .onChange(of: brain.thoughts) { _ in
                    withAnimation { proxy.scrollTo("BottomLog", anchor: .bottom) }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var terminalPane: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("TERMINAL / ACTION LOG", systemImage: "terminal")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(control.actionLog.prefix(100)) { entry in
                        VStack(alignment: .leading, spacing: 2) {
                            Text("[\(entry.timestamp.formatted(date: .omitted, time: .standard))] \(entry.title)")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            Text(entry.detail)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
            }
            .background(Color(NSColor.textBackgroundColor).opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var thinkingPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Mary Thinking")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)

            Text("Task: \(control.selectedTask.rawValue) • Depth: \(control.selectedDepth.rawValue)")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)

            Text("Plan: classify input → ask permission if needed → execute via tools.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.45))
    }

    private var attachmentsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if attachedFiles.isEmpty {
                    Text("Drag files here or click Attach.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(attachedFiles, id: \.self) { url in
                        HStack(spacing: 6) {
                            Image(systemName: "doc")
                            Text(url.lastPathComponent)
                                .lineLimit(1)
                        }
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(NSColor.controlBackgroundColor).opacity(0.65))
                        .clipShape(Capsule())
                    }

                    Button(role: .destructive) {
                        attachedFiles.removeAll()
                    } label: {
                        Label("Clear", systemImage: "trash")
                    }
                    .font(.caption)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    private var composerArea: some View {
        VStack(spacing: 8) {
            TextEditor(text: $userInput)
                .font(.system(size: 15))
                .frame(minHeight: 120, maxHeight: 320)
                .padding(8)
                .background(Color(NSColor.textBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )

            HStack(spacing: 10) {
                Button(action: openFilePicker) {
                    Label("Attach", systemImage: "paperclip")
                }

                Button("Clear Chat") {
                    control.clearChatHistory()
                    brain.thoughts = "> Chat history cleared."
                }
                .buttonStyle(.link)

                Button("Reset Memory") {
                    control.resetAllMemory()
                    brain.thoughts = "> Memory reset complete."
                }
                .buttonStyle(.link)

                Spacer()

                if isProcessing {
                    ProgressView().controlSize(.small)
                } else {
                    Button(action: sendMessage) {
                        Label("Send", systemImage: "paperplane.fill")
                    }
                    .keyboardShortcut(.return, modifiers: .command)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = true

        if panel.runModal() == .OK {
            attachedFiles.append(contentsOf: panel.urls)
            brain.thoughts += "\n> Attached \(panel.urls.count) item(s)."
            control.log("Attachment", "Attached \(panel.urls.count) item(s)")
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                guard let data = item as? Data,
                      let url = NSURL(absoluteURLWithDataRepresentation: data, relativeTo: nil) as URL? else { return }

                DispatchQueue.main.async {
                    attachedFiles.append(url)
                    brain.thoughts += "\n> Dropped file: \(url.lastPathComponent)"
                    control.log("Attachment", "Dropped file: \(url.lastPathComponent)")
                }
            }
        }
        return true
    }

    private func sendMessage() {
        let trimmed = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard !isProcessing else { return }

        Task { @MainActor in
            isProcessing = true

            let classified = control.classifyTask(for: trimmed)
            control.addUserMessage(trimmed)
            control.log("Task Classified", classified.rawValue)

            brain.currentMode = brain.analyzeComplexity(for: trimmed)
            brain.thoughts += "\n> Joe: \(trimmed)"

            if !attachedFiles.isEmpty {
                let names = attachedFiles.map(\.lastPathComponent).joined(separator: ", ")
                brain.thoughts += "\n> Attachments: \(names)"
            }

            userInput = ""
            isProcessing = false
        }
    }

    private var statusFooter: some View {
        HStack {
            Group {
                Text("MODE: \(brain.currentMode.rawValue.uppercased())")
                Separator()
                Text("TASK: \(control.selectedTask.rawValue.uppercased())")
                Separator()
                Text("DEPTH: \(control.selectedDepth.rawValue.uppercased())")
                Separator()
                Text("BACKEND: 8082")
            }
            .font(.system(size: 9, weight: .semibold, design: .monospaced))
            .foregroundColor(.secondary)

            Spacer()

            Button("Reset Environment") {
                brain.thoughts = "> Rebooting context..."
                brain.reset()
                attachedFiles.removeAll()
                control.log("Environment", "Reset requested")
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
