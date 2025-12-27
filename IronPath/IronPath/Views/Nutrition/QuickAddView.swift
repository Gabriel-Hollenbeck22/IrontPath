//
//  QuickAddView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI
import SwiftData

struct QuickAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var nutritionService: NutritionService?
    @State private var name = ""
    @State private var calories: Double = 0
    @State private var protein: Double = 0
    @State private var carbs: Double = 0
    @State private var fat: Double = 0
    @State private var selectedMealType: MealType = .snack
    @State private var isLogging = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Meal Name") {
                    TextField("e.g., Post-Workout Shake", text: $name)
                }
                
                Section("Macros") {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", value: $calories, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Protein (g)")
                        Spacer()
                        TextField("0", value: $protein, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Carbs (g)")
                        Spacer()
                        TextField("0", value: $carbs, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Fat (g)")
                        Spacer()
                        TextField("0", value: $fat, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Meal Type") {
                    Picker("Meal Type", selection: $selectedMealType) {
                        ForEach(MealType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }
            }
            .navigationTitle("Quick Add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Log") {
                        logQuickMeal()
                    }
                    .disabled(isLogging || name.isEmpty)
                }
            }
            .onAppear {
                nutritionService = NutritionService(modelContext: modelContext)
            }
        }
    }
    
    private func logQuickMeal() {
        guard let service = nutritionService else { return }
        
        isLogging = true
        
        do {
            try service.logQuickMeal(
                name: name,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                mealType: selectedMealType
            )
            HapticManager.success()
            dismiss()
        } catch {
            print("Error logging quick meal: \(error)")
            isLogging = false
        }
    }
}

#Preview {
    QuickAddView()
}

