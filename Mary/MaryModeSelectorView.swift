import SwiftUI

/// CLEANED: A high-speed, passive mode selector.
/// It sends the choice to the Brain and gets out of the way.
struct MaryModeSelectorView: View {
    @Binding var selectedMode: MaryWorkMode

    var body: some View {
        HStack(spacing: 4) { // Tighter spacing for faster eye-scanning
            ForEach(MaryWorkMode.allCases) { mode in
                modeButton(for: mode)
            }
        }
        .padding(4)
        .background(MaryTheme.panelBackground.opacity(0.8))
        .cornerRadius(12)
    }

    private func modeButton(for mode: MaryWorkMode) -> some View {
        let isSelected = selectedMode == mode

        return Button {
            selectedMode = mode
        } label: {
            Text(mode.rawValue.uppercased())
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? MaryTheme.accent : Color.clear)
                .foregroundColor(isSelected ? .white : .secondary)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}
