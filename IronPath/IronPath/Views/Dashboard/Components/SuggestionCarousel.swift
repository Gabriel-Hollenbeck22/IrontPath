//
//  SuggestionCarousel.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI

struct SuggestionCarousel: View {
    let suggestions: [SmartSuggestion]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Smart Suggestions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(suggestions) { suggestion in
                        SuggestionCard(suggestion: suggestion)
                            .frame(width: 300)
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }
}

#Preview {
    SuggestionCarousel(
        suggestions: [
            SmartSuggestion(
                id: UUID(),
                type: .recovery,
                priority: .high,
                title: "Low Sleep Detected",
                message: "Consider lighter volume today",
                actionable: true
            )
        ]
    )
    .padding()
}

