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
    let sleepHours: Double?
    let proteinIntake: Double?
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            Text("Recovery Score")
                .font(.cardTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                RecoveryScoreView(score: recoveryScore, size: 150)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    recoveryFactor(
                        label: "Sleep",
                        value: profile.sleepGoalHours,
                        current: sleepHours
                    )
                    
                    recoveryFactor(
                        label: "Protein",
                        value: profile.targetProtein,
                        current: proteinIntake
                    )
                }
            }
        }
        .accentCard()
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
        profile: UserProfile(),
        sleepHours: 7.5,
        proteinIntake: 150.0
    )
    .padding()
}

