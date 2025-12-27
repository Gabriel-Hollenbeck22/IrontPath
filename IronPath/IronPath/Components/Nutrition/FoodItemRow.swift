//
//  FoodItemRow.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI

struct FoodItemRow: View {
    let foodItem: FoodItem
    let sourceLabel: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            HapticManager.selection()
            onTap()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Text(foodItem.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        if foodItem.isHighProtein {
                            Image(systemName: "flame.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                    
                    HStack(spacing: Spacing.sm) {
                        Text("\(Int(foodItem.proteinPer100g))g protein")
                        Text("•")
                        Text("\(Int(foodItem.caloriesPer100g)) kcal")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    Text(sourceLabel)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondaryBackground)
                        .cornerRadius(4)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(Spacing.cardPadding)
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        FoodItemRow(
            foodItem: FoodItem(
                name: "Chicken Breast",
                caloriesPer100g: 165,
                proteinPer100g: 31,
                carbsPer100g: 0,
                fatPer100g: 3.6
            ),
            sourceLabel: "Recent",
            onTap: {}
        )
    }
    .padding()
}

