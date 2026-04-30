//
//  MaryControlCenter.swift
//  Mary
//
//  Created by Joe Zambito on 30/4/2026.
//

import Foundation
import SwiftUI

@MainActor
final class MaryControlCenter: ObservableObject {
    // MARK: - Modes
    enum TaskKind: String, CaseIterable, Identifiable {
        case auto = "Auto"
        case chat = "Chat"
        case code = "Code"
        case debug = "Debug"
        case research = "Research"

        var id: String { rawValue }
    }

    enum Depth: String, CaseIterable, Identifiable {
        case basic = "Basic"
        case normal = "Normal"
        case deep = "Deep"

        var id: String { rawValue }

        var maxTokens: Int {
            switch self {
            case .basic: return 512
            case .normal: return 1536
            case .deep: return 4096
            }
        }
    }

    // MARK: - Permission Model
    enum PermissionScope: String, CaseIterable, Identifiable {
        case readFiles = "Read Files"
        case writeFiles = "Write Files"
        case executeShell = "Execute Shell"
        case network = "Network"
        case destructive = "Destructive"

        var id: String { rawValue }
    }

    struct PermissionRequest: Identifiable {
        let id = UUID()
        let scope: PermissionScope
        let summary: String
        let createdAt: Date
    }

    // MARK: - Action Log
    struct ActionLogEntry: Identifiable {
        let id = UUID()
        let timestamp: Date
        let title: String
        let detail: String
    }

    // MARK: - Memory
    struct ChatMessage: Identifiable, Codable {
        let id: UUID
        let role: String
        let text: String
        let timestamp: Date

        init(id: UUID = UUID(), role: String, text: String, timestamp: Date = Date()) {
            self.id = id
            self.role = role
            self.text = text
            self.timestamp = timestamp
        }
    }

    @Published var selectedTask: TaskKind = .auto
    @Published var selectedDepth: Depth = .normal

    @Published var pendingPermissions: [PermissionRequest] = []
    @Published var actionLog: [ActionLogEntry] = []

    @Published var chatHistory: [ChatMessage] = []
    @Published var projectMemory: [String] = []
    @Published var preferenceMemory: [String: String] = [:]

    private let historyURL: URL
    private let projectMemoryURL: URL
    private let preferencesURL: URL

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Mary", isDirectory: true)
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)

        historyURL = base.appendingPathComponent("chat_history.json")
        projectMemoryURL = base.appendingPathComponent("project_memory.json")
        preferencesURL = base.appendingPathComponent("preferences_memory.json")

        loadAll()
    }

    // MARK: - Public API
    func classifyTask(for text: String) -> TaskKind {
        let lower = text.lowercased()
        if selectedTask != .auto { return selectedTask }

        if lower.contains("error") || lower.contains("crash") || lower.contains("fix") || lower.contains("build failed") {
            return .debug
        }
        if lower.contains("api") || lower.contains("docs") || lower.contains("research") || lower.contains("how to") {
            return .research
        }
        if lower.contains("swift") || lower.contains("code") || lower.contains("refactor") || lower.contains("xcode") {
            return .code
        }
        return .chat
    }

    func enqueuePermission(scope: PermissionScope, summary: String) {
        pendingPermissions.append(.init(scope: scope, summary: summary, createdAt: Date()))
        log("Permission Requested", "\(scope.rawValue): \(summary)")
    }

    func approvePermission(_ id: UUID) {
        pendingPermissions.removeAll { $0.id == id }
        log("Permission Approved", "Request \(id.uuidString.prefix(8)) approved")
    }

    func denyPermission(_ id: UUID) {
        pendingPermissions.removeAll { $0.id == id }
        log("Permission Denied", "Request \(id.uuidString.prefix(8)) denied")
    }

    func addUserMessage(_ text: String) {
        chatHistory.append(.init(role: "user", text: text))
        saveHistory()
    }

    func addMaryMessage(_ text: String) {
        chatHistory.append(.init(role: "assistant", text: text))
        saveHistory()
    }

    func clearChatHistory() {
        chatHistory.removeAll()
        saveHistory()
        log("Memory", "Chat history cleared")
    }

    func clearProjectMemory() {
        projectMemory.removeAll()
        saveProjectMemory()
        log("Memory", "Project memory cleared")
    }

    func setPreference(key: String, value: String) {
        preferenceMemory[key] = value
        savePreferences()
    }

    func resetAllMemory() {
        chatHistory.removeAll()
        projectMemory.removeAll()
        preferenceMemory.removeAll()
        saveAll()
        log("Memory", "Factory reset memory complete")
    }

    func log(_ title: String, _ detail: String) {
        actionLog.insert(.init(timestamp: Date(), title: title, detail: detail), at: 0)
        if actionLog.count > 500 { actionLog.removeLast() }
    }

    // MARK: - Persistence
    private func loadAll() {
        loadHistory()
        loadProjectMemory()
        loadPreferences()
    }

    private func saveAll() {
        saveHistory()
        saveProjectMemory()
        savePreferences()
    }

    private func loadHistory() {
        guard let data = try? Data(contentsOf: historyURL),
              let decoded = try? JSONDecoder().decode([ChatMessage].self, from: data) else { return }
        chatHistory = decoded
    }

    private func saveHistory() {
        guard let data = try? JSONEncoder().encode(chatHistory) else { return }
        try? data.write(to: historyURL, options: .atomic)
    }

    private func loadProjectMemory() {
        guard let data = try? Data(contentsOf: projectMemoryURL),
              let decoded = try? JSONDecoder().decode([String].self, from: data) else { return }
        projectMemory = decoded
    }

    private func saveProjectMemory() {
        guard let data = try? JSONEncoder().encode(projectMemory) else { return }
        try? data.write(to: projectMemoryURL, options: .atomic)
    }

    private func loadPreferences() {
        guard let data = try? Data(contentsOf: preferencesURL),
              let decoded = try? JSONDecoder().decode([String: String].self, from: data) else { return }
        preferenceMemory = decoded
    }

    private func savePreferences() {
        guard let data = try? JSONEncoder().encode(preferenceMemory) else { return }
        try? data.write(to: preferencesURL, options: .atomic)
    }
}
