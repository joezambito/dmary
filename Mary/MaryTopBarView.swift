import SwiftUI

/// CLEANED: A high-performance top bar.
/// Optimized to prevent GPU overdraw during high-speed text streaming.
struct MaryTopBarView: View {
    @Binding var selectedMode: MaryWorkMode

    var body: some View {
        HStack(spacing: 20) {
            // Branding & Status
            VStack(alignment: .leading, spacing: 2) {
                Text("MARY")
                    .font(.system(size: 18, weight: .black, design: .monospaced))
                
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("ACTIVE BRIDGE: 8082")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Mode Selector
            MaryModeSelectorView(selectedMode: $selectedMode)
                .scaleEffect(0.9) // Keep the UI compact
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        // 🎯 CRITICAL: Solid background to prevent blending lag
        .background(MaryTheme.panelBackground) 
        .overlay(alignment: .bottom) {
            Divider().opacity(0.5)
        }
    }
}
