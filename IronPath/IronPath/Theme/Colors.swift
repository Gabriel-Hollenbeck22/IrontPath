//
//  Colors.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI

extension Color {
    // MARK: - Primary Colors
    
    /// Bright blue - Primary brand color
    static let ironPathPrimary = Color(red: 0.2, green: 0.6, blue: 1.0)
    
    /// Orange - Accent color for highlights
    static let ironPathAccent = Color(red: 1.0, green: 0.45, blue: 0.0)
    
    // MARK: - Semantic Colors
    
    /// Success state (green)
    static let ironPathSuccess = Color.green
    
    /// Warning state (orange)
    static let ironPathWarning = Color.orange
    
    /// Danger/Error state (red)
    static let ironPathDanger = Color.red
    
    /// Error state alias (red)
    static let ironPathError = Color.red
    
    // MARK: - Macro Colors
    
    /// Protein color (blue)
    static let macroProtein = Color(red: 0.2, green: 0.6, blue: 1.0)
    
    /// Carbs color (orange)
    static let macroCarbs = Color(red: 1.0, green: 0.45, blue: 0.0)
    
    /// Fat color (purple)
    static let macroFat = Color(red: 0.6, green: 0.4, blue: 0.9)
    
    // MARK: - Recovery Score Colors
    
    /// High recovery (80-100)
    static let recoveryHigh = Color.green
    
    /// Medium recovery (60-79)
    static let recoveryMedium = Color.yellow
    
    /// Low recovery (0-59)
    static let recoveryLow = Color.red
    
    // MARK: - Background Colors
    
    /// Glassmorphic card background
    static let cardBackground = Color(.systemBackground).opacity(0.7)
    
    /// Secondary background
    static let secondaryBackground = Color(.secondarySystemBackground)
    
    // MARK: - Glass & Glow Effects
    
    /// Glass background for premium cards
    static let glassBackground = Color.white.opacity(0.06)
    
    /// Glass border color
    static let glassBorder = Color.white.opacity(0.08)
    
    /// Primary color glow effect
    static let glowPrimary = Color.ironPathPrimary.opacity(0.5)
    
    /// Subtle gradient top for backgrounds
    static let subtleGradientTop = Color.black
    
    /// Subtle gradient bottom for backgrounds
    static let subtleGradientBottom = Color(.systemGray6).opacity(0.08)
}

