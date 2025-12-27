//
//  HapticManager.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import UIKit

enum HapticManager {
    // MARK: - Impact Feedback
    
    /// Light impact - For selections, taps
    static func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Medium impact - For confirmations, state changes
    static func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// Heavy impact - For significant actions
    static func heavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    // MARK: - Notification Feedback
    
    /// Success notification - For workout complete, goal achieved
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Warning notification - For warnings
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    /// Error notification - For errors
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - Selection Feedback
    
    /// Selection feedback - For picker changes
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

