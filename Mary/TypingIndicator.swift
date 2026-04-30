//
//  TypingIndicator.swift
//  Mary
//
//  Created by Joe Zambito on 25/4/2026.
//

import SwiftUI

/// CLEANED: A low-impact visual heartbeat.
/// Optimized to minimize CPU usage while the Brain is under heavy load.
struct TypingIndicator: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundStyle(Color.secondary.opacity(0.6))
                    .scaleEffect(isAnimating ? 1.0 : 0.7)
                    .opacity(isAnimating ? 1.0 : 0.4)
                    .animation(
                        .easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.25),
                        value: isAnimating
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.primary.opacity(0.05))
        .clipShape(Capsule())
        .onAppear { isAnimating = true }
    }
}
