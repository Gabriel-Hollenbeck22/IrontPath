//
//  CardStyles.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI

// MARK: - Premium Card Modifier

/// Enhanced glass card with layered gradient, border, and glow effect
struct PremiumCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Spacing.cardPadding)
            .background(
                ZStack {
                    // Base gradient background
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    Color.white.opacity(0.02)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Subtle inner highlight
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.05),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 16, x: 0, y: 10)
    }
}

// MARK: - Nested Card Modifier

/// Lighter card for nested content within other cards
struct NestedCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
            )
    }
}

// MARK: - Accent Card Modifier

/// Card with subtle primary color glow for emphasis
struct AccentCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Spacing.cardPadding)
            .background(
                ZStack {
                    // Gradient background with accent tint
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.ironPathPrimary.opacity(0.08),
                                    Color.white.opacity(0.02)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.ironPathPrimary.opacity(0.3),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.ironPathPrimary.opacity(0.2), radius: 20, x: 0, y: 10)
            .shadow(color: Color.black.opacity(0.3), radius: 16, x: 0, y: 10)
    }
}

// MARK: - View Extensions

extension View {
    /// Apply premium glass card styling
    func premiumCard() -> some View {
        modifier(PremiumCardModifier())
    }
    
    /// Apply nested card styling for content within cards
    func nestedCard() -> some View {
        modifier(NestedCardModifier())
    }
    
    /// Apply accent card styling with primary color glow
    func accentCard() -> some View {
        modifier(AccentCardModifier())
    }
}
