import SwiftUI

/// CLEANED: A passive settings panel.
/// It triggers actions but does not manage the 'Logic' of how Mary works.
struct MarySettingsPanel: View {
    let onClose: () -> Void
    let onClearChat: () -> Void
    let onClearLibrary: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Settings")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                    Text("Workspace Configuration")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 10)

            // Workspace Management
            settingsCard(title: "Session", icon: "terminal.fill") {
                SettingsActionRow(
                    title: "Clear Chat", 
                    subtitle: "Wipe current session history", 
                    icon: "trash", 
                    role: .destructive, 
                    action: onClearChat
                )
            }

            // Memory Management
            settingsCard(title: "Project Memory", icon: "cpu") {
                SettingsActionRow(
                    title: "Purge Library", 
                    subtitle: "Delete all learned project context", 
                    icon: "exclamationmark.shield.fill", 
                    role: .destructive, 
                    action: onClearLibrary
                )
            }

            Spacer()
        }
        .padding(20)
        .frame(width: 320)
        .background(MaryTheme.panelBackground)
        .shadow(color: .black.opacity(0.1), radius: 10)
    }

    private func settingsCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.caption).foregroundStyle(MaryTheme.accent)
                Text(title.uppercased()).font(.system(size: 10, weight: .black))
            }
            content()
        }
        .padding(12)
        .background(Color.primary.opacity(0.03))
        .cornerRadius(10)
    }
}

struct SettingsActionRow: View {
    enum Role { case normal, destructive }
    let title: String
    let subtitle: String
    let icon: String
    var role: Role = .normal
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(role == .destructive ? .red : MaryTheme.accent)
                    .font(.system(size: 14))
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(title).font(.system(size: 13, weight: .semibold))
                    Text(subtitle).font(.system(size: 11)).foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}
