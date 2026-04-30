//
//  MainApp.swift
//  Mary
//
//  Created by Joe Zambito on 25/4/2026.
//

//
//  MainApp.swift
//  Mary
//
//  Created by Joe Zambito on 25/4/2026.
//

import SwiftUI

@main
struct MaryApp: App {
    @StateObject private var brain = MaryReasoningEngine()
    @StateObject private var settings = SettingsManager.shared
    private static var didLogLaunch = false

    init() {
        if !Self.didLogLaunch {
            Self.didLogLaunch = true
            LogManager.shared.append("App launched. Environment: M2 Pro / Port 8082.")
        }
    }

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
    @State private var didBoot = false

    var body: some View {
        NavigationSplitView {
            MaryChatWorkspaceView()
                .navigationSplitViewColumnWidth(min: 250, ideal: 300)
        } detail: {
            MaryChatWorkspaceView()
                .frame(minWidth: 700)
        }
        .onAppear {
            guard !didBoot else { return }
            didBoot = true
            bootMary()
        }
    }

    private func bootMary() {
        Task { @MainActor in
            brain.thoughts = """
            > Mary System Boot Complete.
            > Port 8082: Listening.
            > Context Window: Optimized for M2 Silicon.
            """
        }
    }
}
