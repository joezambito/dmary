import SwiftUI

/// CLEANED: A high-performance sidebar.
/// Optimized for the M2 Pro to keep redraw costs near zero.
struct MarySidebarView: View {
    @Binding var selectedSection: MaryDashboardSection
    @Binding var showSettings: Bool

    var body: some View {
        VStack(spacing: 20) {
            // Minimalist Logo
            Circle()
                .fill(MaryTheme.accent)
                .frame(width: 40, height: 40)
                .overlay(
                    Text("M")
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                )
                .padding(.top, 24)

            // Navigation List
            VStack(spacing: 8) {
                ForEach(MaryDashboardSection.allCases) { section in
                    sidebarButton(section)
                }
            }

            Spacer()

            // Settings Trigger
            Button {
                showSettings.toggle()
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .background(showSettings ? MaryTheme.accent.opacity(0.15) : Color.clear)
                    .foregroundColor(showSettings ? MaryTheme.accent : .secondary)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 24)
        }
        .frame(width: 80)
        .background(MaryTheme.sidebarBackground)
        .overlay(alignment: .trailing) { Divider() }
    }

    private func sidebarButton(_ section: MaryDashboardSection) -> some View {
        let isSelected = selectedSection == section
        
        return Button {
            selectedSection = section
        } label: {
            VStack(spacing: 4) {
                Image(systemName: section.icon)
                    .font(.system(size: 18, weight: isSelected ? .bold : .regular))
                Text(section.rawValue)
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundColor(isSelected ? MaryTheme.accent : .secondary)
            .frame(width: 64, height: 56)
            .background(isSelected ? MaryTheme.accent.opacity(0.1) : Color.clear)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}
