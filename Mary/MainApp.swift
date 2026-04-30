//
//  MainApp.swift
//  Mary
//
//  Created by Joe Zambito on 25/4/2026.
//

import SwiftUI

@main
struct MaryApp: App {
    // 🏎️ Initialized once at root to prevent Brain re-allocation
    @StateObject private var brain = MaryReasoningEngine()
    @StateObject private var settings = SettingsManager.shared

    var body: some Scene {
        WindowGroup {
            MaryMainView()
                .environmentObject(brain)
                .environmentObject(settings)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
    }
}

struct MaryMainView: View {
    @EnvironmentObject var brain: MaryReasoningEngine
    
    var body: some View {
        NavigationSplitView {
            // SIDEBAR: Library & Context
            MaryChatWorkspaceView()
                .navigationSplitViewColumnWidth(min: 250, ideal: 300)
            
        } detail: {
            // MAIN: Chat & Coding Workspace
            MaryChatWorkspaceView()
                .frame(minWidth: 700)
        }
        .onAppear(perform: bootMary)
    }
    
    private func bootMary() {
        LogManager.shared.append("App launched. Environment: M2 Pro / Port 8082.")
        
        // Passive diagnostic boot
        Task {
            brain.thoughts = """
            > Mary System Boot Complete.
            > Port 8082: Listening.
            > Context Window: Optimized for M2 Silicon.
            """
        }
    }
}
