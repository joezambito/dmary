import SwiftUI

/// CLEANED: This is now a Pure Interface. 
/// It reports toggles to the Main Brain but doesn't execute 'renice' commands itself.
struct MaryLibraryView: View {
    var attachedFiles: [URL] = []

    @StateObject var memory = MaryProjectMemory()
    @State private var lowPowerMode = false
    @State private var turboBoost = true
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("ENGINE OPTIMIZATIONS")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                // Turbo Toggle: Now just a signal reporter
                Toggle(isOn: $turboBoost) {
                    VStack(alignment: .leading) {
                        Text("M2 Turbo Boost")
                            .font(.subheadline)
                        Text("Requests higher priority from Main Brain")
                            .font(.caption2).foregroundColor(.secondary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .orange))
                .onChange(of: turboBoost) { newValue in
                    // Report the state change. The Brain handles the 'renice' logic elsewhere.
                    print("UI Signal: Turbo Boost is now \(newValue)")
                }
                
                Toggle(isOn: $lowPowerMode) {
                    VStack(alignment: .leading) {
                        Text("Efficiency Mode")
                            .font(.subheadline)
                        Text("Requests background throttling")
                            .font(.caption2).foregroundColor(.secondary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .green))
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
            
            Divider().padding(.vertical)
            
            Text("PROJECT ASSETS")
                .font(.headline)
                .padding(.horizontal)
            
            // CLEANED: Simplified List. 
            // Filtering logic should be handled by a ViewModel or the Main Brain.
            List {
                ForEach(memory.entries) { entry in
                    HStack {
                        Image(systemName: entry.type == .codeSnippet ? "doc.text.fill" : "photo.fill")
                        VStack(alignment: .leading) {
                            Text(entry.project)
                                .font(.caption).foregroundColor(.blue)
                            Text(entry.content.prefix(30) + "...")
                                .font(.system(size: 11, design: .monospaced))
                        }
                    }
                }
            }
        }
        .frame(width: 250)
    }
}
