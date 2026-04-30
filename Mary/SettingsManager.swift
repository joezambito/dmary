//
//  SettingsManager.swift
//  Mary
//
//  Created by Joe Zambito on 25/4/2026.
//

//
import Foundation
import Combine

/// THE CONSTRAINTS: Defines the physical and logical boundaries for the Brain.
public struct Settings: Codable {
    public var username: String = "Joe"
    public var maxMessagesToKeep: Int = 10 // 🏎️ Defaulting to 10 for M2 speed
    public var localBackendURL: String = "http://127.0.0.1:8082"
    
    // Performance Toggles
    public var verboseLogging: Bool = false
    public var useNeuralEngine: Bool = true // A hint for the Brain to stay lean
    
    public static func defaults() -> Settings {
        Settings()
    }
}

/// THE MANAGER: A thread-safe publisher for global configuration.
public final class SettingsManager: ObservableObject {
    public static let shared = SettingsManager()

    @Published public var settings: Settings

    private init() {
        self.settings = Settings.defaults()
    }

    public func resetToDefaults() {
        settings = Settings.defaults()
    }
}
