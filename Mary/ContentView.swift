import SwiftUI

/// THE MAIN FRAME: The high-performance hull for Mary's Brain.
struct ContentView: View {
    @StateObject var viewModel = ChatViewModel()
    @State private var selectedSection: MaryDashboardSection = .chat
    @State private var showSettings = false
    @State private var selectedMode: MaryWorkMode = .normal

    var body: some View {
        ZStack(alignment: .trailing) {
            HStack(spacing: 0) {
                // PASSIVE SIDEBAR: Minimal GPU impact
                MarySidebarView(
                    selectedSection: $selectedSection,
                    showSettings: $showSettings
                )
                .frame(width: 80) // Fixed width for consistent dev layout

                VStack(spacing: 0) {
                    // THE ROOF: Solid background to prevent scrolling overdraw
                    MaryTopBarView(selectedMode: $selectedMode)
                    
                    Divider()

                    // DYNAMIC WORKSPACE
                    mainWorkArea
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            // SETTINGS OVERLAY: A high-speed, spring-loaded panel
            if showSettings {
                settingsOverlay
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .zIndex(2)
            }
        }
        .frame(minWidth: 1200, minHeight: 800)
        .background(MaryTheme.appBackground)
        .preferredColorScheme(.dark) // Keeps Mary in "Developer Mode" by default
    }

    // MARK: - Subviews
    
    private var mainWorkArea: some View {
        Group {
            switch selectedSection {
            case .chat:
                MaryChatWorkspaceView()
            case .library:
                MaryLibraryView(attachedFiles: viewModel.attachedFiles)
            @unknown default:
                MaryChatWorkspaceView()
            }
        }
    }
    private var settingsOverlay: some View {
        MarySettingsPanel(
            onClose: {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                    showSettings = false
                }
            },
            onClearChat: { viewModel.clearChat() },
            onClearLibrary: { viewModel.attachedFiles.removeAll() }
        )
        .frame(width: 350)
        .background(MaryTheme.panelBackground)
        .shadow(color: .black.opacity(0.3), radius: 20, x: -10)
    }
}
