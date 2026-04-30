import SwiftUI
import AppKit
import UniformTypeIdentifiers

// Local-only enum name to avoid collisions with existing project types
enum MaryWorkspacePaneMode: String, CaseIterable, Identifiable {
    case chat = "Chat"
    case terminal = "Terminal"
    case both = "Both"

    var id: String { rawValue }
}

// Local-only enum name to avoid collisions
enum MaryWorkspaceTaskMode: String, CaseIterable, Identifiable {
    case auto = "Auto"
    case chat = "Chat"
    case code = "Code"
    case debug = "Debug"
    case research = "Research"

    var id: String { rawValue }
}

struct MaryChatWorkspaceView: View {
    @EnvironmentObject var brain: MaryReasoningEngine
    @EnvironmentObject var settings: SettingsManager

    @State private var userInput: String = ""
    @State private var isProcessing: Bool = false

    @State private var paneMode: MaryWorkspacePaneMode = .chat
    @State private var taskMode: MaryWorkspaceTaskMode = .auto
    @State private var showThinkingPanel: Bool = true

    @State private var attachedFiles: [URL] = []

    // Keep local depth enum out to avoid redeclaration; use plain string state
    @State private var depthSelection: String = "Normal"
    private let depthOptions = ["Basic", "Normal", "Deep"]

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

    // MARK: - Top Bar
    private var topBar: some View {
        HStack(spacing: 12) {
            Picker("View", selection: $paneMode) {
                ForEach(MaryWorkspacePaneMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 220)

            Picker("Task", selection: $taskMode) {
                ForEach(MaryWorkspaceTaskMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 360)

            Picker("Depth", selection: $depthSelection) {
                ForEach(depthOptions, id: \.self) { value in
                    Text(value).tag(value)
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

    // MARK: - Content
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
            Label("TERMINAL / TOOL LOG", systemImage: "terminal")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("This pane is ready for live terminal stream integration.")
                    Text("Use it for commands, outputs, and permission actions.")
                }
                .font(.system(.body, design: .monospaced))
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

            Text("Task: \(taskMode.rawValue) • Depth: \(depthSelection)")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)

            Text("Flow: Interpret → plan → request permission (if needed) → act.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.45))
    }

    // MARK: - Attachments
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

    // MARK: - Composer
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

                Text("⌘↩ Send")
                    .font(.caption)
                    .foregroundColor(.secondary)

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

    // MARK: - Actions
    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = true

        if panel.runModal() == .OK {
            attachedFiles.append(contentsOf: panel.urls)
            brain.thoughts += "\n> Attached \(panel.urls.count) item(s)."
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

            // Keep authority in brain
            brain.currentMode = brain.analyzeComplexity(for: trimmed)
            brain.thoughts += "\n> Joe: \(trimmed)"

            if !attachedFiles.isEmpty {
                brain.thoughts += "\n> Attachments: \(attachedFiles.map { $0.lastPathComponent }.joined(separator: ", "))"
            }

            // Keep networking layer intact elsewhere
            userInput = ""
            isProcessing = false
        }
    }

    // MARK: - Footer
    private var statusFooter: some View {
        HStack {
            Group {
                Text("MODE: \(brain.currentMode.rawValue.uppercased())")
                Separator()
                Text("TASK: \(taskMode.rawValue.uppercased())")
                Separator()
                Text("DEPTH: \(depthSelection.uppercased())")
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
