//
//  FormatHelpers.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import Foundation

enum FormatHelpers {
    // MARK: - Weight Formatting
    
    /// Format weight in pounds
    static func weight(_ pounds: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return "\(formatter.string(from: NSNumber(value: pounds)) ?? "0") lbs"
    }
    
    /// Format weight in kilograms
    static func weightKg(_ kilograms: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return "\(formatter.string(from: NSNumber(value: kilograms)) ?? "0") kg"
    }
    
    // MARK: - Macro Formatting
    
    /// Format macros (protein, carbs, fat)
    static func macro(_ grams: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return "\(formatter.string(from: NSNumber(value: grams)) ?? "0")g"
    }
    
    /// Format calories
    static func calories(_ calories: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return "\(formatter.string(from: NSNumber(value: calories)) ?? "0") kcal"
    }
    
    // MARK: - Time Formatting
    
    /// Format duration in seconds to MM:SS
    static func duration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    /// Format rest timer (seconds to MM:SS)
    static func restTimer(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    // MARK: - Date Formatting
    
    /// Format date for display
    static func date(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    /// Format time for display
    static func time(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - Percentage Formatting
    
    /// Format percentage
    static func percentage(_ value: Double, max: Double = 100) -> String {
        let percent = (value / max) * 100
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return "\(formatter.string(from: NSNumber(value: percent)) ?? "0")%"
    }
}

