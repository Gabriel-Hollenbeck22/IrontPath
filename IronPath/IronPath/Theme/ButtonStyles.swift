//
//  ButtonStyles.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI

// MARK: - Neon Glow Button Style

/// Primary button style with soft color glow and scale animation
struct NeonGlowButtonStyle: ButtonStyle {
    var color: Color = .ironPathPrimary
    var textColor: Color = .white
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(color)
            .cornerRadius(12)
            .shadow(color: color.opacity(0.5), radius: 18, x: 0, y: 6)
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 3)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Glass Button Style

/// Secondary button style with glass effect
struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Compact Button Style

/// Smaller button style for inline actions
struct CompactButtonStyle: ButtonStyle {
    var color: Color = .ironPathPrimary
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(color)
            .cornerRadius(8)
            .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    /// Apply neon glow button style with custom color
    func neonGlowButton(color: Color = .ironPathPrimary, textColor: Color = .white) -> some View {
        buttonStyle(NeonGlowButtonStyle(color: color, textColor: textColor))
    }
    
    /// Apply glass button style
    func glassButton() -> some View {
        buttonStyle(GlassButtonStyle())
    }
    
    /// Apply compact button style
    func compactButton(color: Color = .ironPathPrimary) -> some View {
        buttonStyle(CompactButtonStyle(color: color))
    }
}
