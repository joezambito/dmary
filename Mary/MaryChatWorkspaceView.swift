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

    @State private var showingDeleteThreadConfirm = false
    @State private var threadToDelete: UUID?
    @State private var showingClearAllConfirm = false

    var body: some View {
        HStack(spacing: 0) {
            threadSidebar
                .frame(width: 260)
                .background(MaryTheme.panelBackground)

            Divider()

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
        .confirmationDialog("Delete this chat thread?", isPresented: $showingDeleteThreadConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let id = threadToDelete {
                    control.deleteThread(id)
                    brain.thoughts += "\n> Deleted thread."
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Clear ALL chat threads?", isPresented: $showingClearAllConfirm, titleVisibility: .visible) {
            Button("Clear All", role: .destructive) {
                control.clearAllThreads()
                brain.thoughts += "\n> Cleared all chat threads."
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Left Sidebar (Threads)
    private var threadSidebar: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Chats")
                    .font(.headline)
                Spacer()
                Button {
                    control.createNewThread()
                    brain.thoughts += "\n> New chat created."
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(control.chatThreads) { thread in
                        threadRow(thread: thread)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 10)
            }

            Divider()

            HStack(spacing: 8) {
                Button("Clear All") {
                    showingClearAllConfirm = true
                }
                .buttonStyle(.link)

                Spacer()

                Button("Reset Memory") {
                    control.resetAllMemory()
                    brain.thoughts = "> Memory reset complete."
                }
                .buttonStyle(.link)
            }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
        }
    }

    private func threadRow(thread: MaryControlCenter.ChatThread) -> some View {
        let isActive = thread.id == control.activeThreadID

        return HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(thread.title)
                    .font(.system(size: 12, weight: isActive ? .semibold : .regular))
                    .lineLimit(1)

                Text("\(thread.messages.count) msg • \(thread.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                threadToDelete = thread.id
                showingDeleteThreadConfirm = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 11))
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
        .padding(8)
        .background(isActive ? Color.accentColor.opacity(0.16) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())
        .onTapGesture {
            control.selectThread(thread.id)
            loadActiveThreadIntoReasoningStream()
        }
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

    // MARK: - Main Content Area
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

    // MARK: - Chat Pane
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

    // MARK: - Terminal Pane
    private var terminalPane: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("TERMINAL / ACTION LOG", systemImage: "terminal")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(control.actionLog.prefix(150)) { entry in
                        VStack(alignment: .leading, spacing: 2) {
                            Text("[\(entry.timestamp.formatted(date: .omitted, time: .standard))] \(entry.title)")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            Text(entry.detail)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    }

                    if control.actionLog.isEmpty {
                        Text("No actions yet.")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.secondary)
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

    // MARK: - Thinking Panel
    private var thinkingPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Mary Thinking")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)

            Text("Task: \(control.selectedTask.rawValue) • Depth: \(control.selectedDepth.rawValue)")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)

            Text("Plan: classify input → decide tool path → ask permission where required.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.45))
    }

    // MARK: - Attachments Row
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
                        control.log("Attachment", "Cleared attachment list")
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

                Button("Clear Active Chat") {
                    guard let id = control.activeThreadID else { return }
                    control.deleteThread(id)
                    control.createNewThread()
                    brain.thoughts = "> Active chat cleared."
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

    // MARK: - Actions
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

            // Keep MaryBrain authority
            brain.currentMode = brain.analyzeComplexity(for: trimmed)
            brain.thoughts += "\n> Joe: \(trimmed)"

            if !attachedFiles.isEmpty {
                let names = attachedFiles.map(\.lastPathComponent).joined(separator: ", ")
                brain.thoughts += "\n> Attachments: \(names)"
            }

            // You can plug the LLM response pipeline here next.
            // For now this preserves your current behavior cleanly.
            userInput = ""
            isProcessing = false
        }
    }

    private func loadActiveThreadIntoReasoningStream() {
        guard let thread = control.activeThread else { return }

        let rendered = thread.messages.map { message in
            let prefix = message.role == "user" ? "Joe" : "Mary"
            return "> \(prefix): \(message.text)"
        }.joined(separator: "\n")

        brain.thoughts = rendered.isEmpty ? "> Switched to thread: \(thread.title)" : rendered
    }

    // MARK: - Footer
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
