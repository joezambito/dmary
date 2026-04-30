//
//  SettingsView.swift
//  Mary
//
//  Created by Joe Zambito on 25/4/2026.
//

import SwiftUI

/// CLEANED: A high-performance settings interface.
/// Directly manipulates the SettingsManager to update Brain behavior in real-time.
struct SettingsView: View {
    @ObservedObject var settingsManager = SettingsManager.shared

    var body: some View {
        Form {
            Section {
                LabeledContent("Username") {
                    TextField("Joe", text: $settingsManager.settings.username)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 200)
                }
            } header: {
                Text("Identity")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            Section {
                LabeledContent("Local Backend") {
                    TextField("http://...", text: $settingsManager.settings.localBackendURL)
                        .textFieldStyle(.roundedBorder)
                }
                
                Toggle("Verbose Logging", isOn: $settingsManager.settings.verboseLogging)
                Toggle("Neural Engine Optimization", isOn: $settingsManager.settings.useNeuralEngine)
            } header: {
                Text("Technical Bridge")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Stepper("Context Window: \(settingsManager.settings.maxMessagesToKeep) messages", 
                            value: $settingsManager.settings.maxMessagesToKeep, in: 5...20)
                    
                    Text("Lower limits increase speed on M2 Silicon.")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            } header: {
                Text("Memory Constraints")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .padding(.vertical, 10)

            Button(role: .destructive) {
                settingsManager.resetToDefaults()
            } label: {
                Text("Reset Mary to Factory Defaults")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .formStyle(.grouped)
        .padding(20)
        .navigationTitle("Mary Configuration")
        .frame(minWidth: 400, minHeight: 500)
    }
}
