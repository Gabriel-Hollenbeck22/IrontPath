//
//  MacroProgressSection.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI

struct MacroProgressSection: View {
    let summary: DailySummary
    let profile: UserProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Today's Macros")
                .font(.cardTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: Spacing.lg) {
                MacroRingView(
                    current: summary.totalProtein,
                    target: profile.targetProtein,
                    color: .macroProtein,
                    label: "Protein"
                )
                
                MacroRingView(
                    current: summary.totalCarbs,
                    target: profile.targetCarbs,
                    color: .macroCarbs,
                    label: "Carbs"
                )
                
                MacroRingView(
                    current: summary.totalFat,
                    target: profile.targetFat,
                    color: .macroFat,
                    label: "Fat"
                )
            }
            .frame(maxWidth: .infinity)
        }
        .premiumCard()
    }
}

#Preview {
    MacroProgressSection(
        summary: DailySummary(date: Date()),
        profile: UserProfile()
    )
    .padding()
}

