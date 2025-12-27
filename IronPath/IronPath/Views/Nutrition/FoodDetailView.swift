//
//  FoodDetailView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI
import SwiftData

struct FoodDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let foodItem: FoodItem
    
    @State private var nutritionService: NutritionService?
    @State private var servingSizeGrams: Double = 100
    @State private var selectedMealType: MealType = .lunch
    @State private var isLogging = false
    
    var macros: MacroNutrients {
        foodItem.macrosForServing(servingSizeGrams)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.sectionSpacing) {
                    // Food Info
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text(foodItem.name)
                            .font(.title2)
                        
                        if let brand = foodItem.brand {
                            Text(brand)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        // Macros per 100g
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            macroRow(label: "Calories", value: FormatHelpers.calories(foodItem.caloriesPer100g))
                            macroRow(label: "Protein", value: FormatHelpers.macro(foodItem.proteinPer100g))
                            macroRow(label: "Carbs", value: FormatHelpers.macro(foodItem.carbsPer100g))
                            macroRow(label: "Fat", value: FormatHelpers.macro(foodItem.fatPer100g))
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                    }
                    
                    // Serving Size Picker
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Serving Size")
                            .font(.headline)
                        
                        VStack(spacing: Spacing.sm) {
                            HStack {
                                Text("\(Int(servingSizeGrams))g")
                                    .font(.headline)
                                    .frame(minWidth: 80)
                                
                                Slider(value: $servingSizeGrams, in: 10...500, step: 10)
                            }
                            
                            // Quick serving buttons
                            HStack(spacing: Spacing.sm) {
                                ForEach([50, 100, 150, 200], id: \.self) { grams in
                                    Button("\(grams)g") {
                                        servingSizeGrams = Double(grams)
                                        HapticManager.selection()
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(servingSizeGrams == Double(grams) ? .ironPathPrimary : .gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                    }
                    
                    // Selected Serving Macros
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Selected Serving")
                            .font(.headline)
                        
                        VStack(spacing: Spacing.sm) {
                            macroRow(label: "Calories", value: FormatHelpers.calories(macros.calories))
                            macroRow(label: "Protein", value: FormatHelpers.macro(macros.protein))
                            macroRow(label: "Carbs", value: FormatHelpers.macro(macros.carbs))
                            macroRow(label: "Fat", value: FormatHelpers.macro(macros.fat))
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                    }
                    
                    // Meal Type Picker
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Meal Type")
                            .font(.headline)
                        
                        Picker("Meal Type", selection: $selectedMealType) {
                            ForEach(MealType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Log Button
                    HapticButton(hapticStyle: .success) {
                        logFood()
                    } label: {
                        Label("Log Food", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isLogging ? Color.gray : Color.ironPathSuccess)
                            .cornerRadius(12)
                    }
                    .disabled(isLogging)
                }
                .padding()
            }
            .navigationTitle("Food Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                nutritionService = NutritionService(modelContext: modelContext)
            }
        }
    }
    
    private func macroRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.headline)
        }
    }
    
    private func logFood() {
        guard let service = nutritionService else { return }
        
        isLogging = true
        
        do {
            try service.logFood(
                foodItem: foodItem,
                servingSizeGrams: servingSizeGrams,
                mealType: selectedMealType
            )
            HapticManager.success()
            dismiss()
        } catch {
            print("Error logging food: \(error)")
            isLogging = false
        }
    }
}

#Preview {
    FoodDetailView(
        foodItem: FoodItem(
            name: "Chicken Breast",
            caloriesPer100g: 165,
            proteinPer100g: 31,
            carbsPer100g: 0,
            fatPer100g: 3.6
        )
    )
}

