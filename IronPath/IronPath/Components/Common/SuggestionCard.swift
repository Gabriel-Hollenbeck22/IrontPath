//
//  SuggestionCard.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI

struct SuggestionCard: View {
    let suggestion: SmartSuggestion
    
    var iconName: String {
        switch suggestion.type {
        case .nutrition:
            return "fork.knife"
        case .workout:
            return "dumbbell.fill"
        case .recovery:
            return "bed.double.fill"
        case .general:
            return "info.circle.fill"
        }
    }
    
    var priorityColor: Color {
        switch suggestion.priority {
        case .high:
            return .ironPathDanger
        case .medium:
            return .ironPathWarning
        case .low:
            return .ironPathPrimary
        }
    }
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundStyle(priorityColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(suggestion.title)
                    .font(.headline)
                
                Text(suggestion.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(Spacing.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

#Preview {
    VStack(spacing: 12) {
        SuggestionCard(
            suggestion: SmartSuggestion(
                id: UUID(),
                type: .recovery,
                priority: .high,
                title: "Low Sleep Detected",
                message: "Recovery Alert: Consider 10% volume reduction for safety.",
                actionable: true
            )
        )
        
        SuggestionCard(
            suggestion: SmartSuggestion(
                id: UUID(),
                type: .nutrition,
                priority: .medium,
                title: "Low Protein Intake",
                message: "Protein intake below optimal for muscle synthesis.",
                actionable: true
            )
        )
    }
    .padding()
}

