import SwiftUI
import AppKit

/// CLEANED: Optimized for M2 Unified Memory.
/// Uses semantic system colors to minimize GPU overdraw during AI streaming.
struct MaryTheme {
    // Backgrounds
    static let appBackground = Color(NSColor.windowBackgroundColor)
    static let sidebarBackground = Color(NSColor.underPageBackgroundColor)
    static let panelBackground = Color(NSColor.controlBackgroundColor)
    
    // Borders & Accents
    static let softBorder = Color.primary.opacity(0.08)
    static let accent = Color.accentColor
    static let warning = Color.red
    
    // Typography
    static let mainText = Color.primary
    static let softText = Color.secondary
    
    // Geometry (Constants are faster than computed properties)
    static let cardRadius: CGFloat = 12
    static let pillRadius: CGFloat = 8
    
    // Efficiency Note: Use standard shapes with these colors 
    // to avoid triggering heavy CoreAnimation layer blurs.
}
