//
//  RecoveryScoreCard.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI

struct RecoveryScoreCard: View {
    let recoveryScore: Double
    let profile: UserProfile
    
    var body: some View {
        GlassMorphicCard {
            VStack(spacing: Spacing.md) {
                Text("Recovery Score")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    RecoveryScoreView(score: recoveryScore, size: 150)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        recoveryFactor(
                            label: "Sleep",
                            value: profile.sleepGoalHours,
                            current: nil // TODO: Get from HealthKit
                        )
                        
                        recoveryFactor(
                            label: "Protein",
                            value: profile.targetProtein,
                            current: nil // TODO: Get from today's summary
                        )
                    }
                }
            }
        }
    }
    
    private func recoveryFactor(label: String, value: Double, current: Double?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if let current = current {
                Text("\(Int(current)) / \(Int(value))")
                    .font(.headline)
            } else {
                Text("--")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    RecoveryScoreCard(
        recoveryScore: 85,
        profile: UserProfile()
    )
    .padding()
}

