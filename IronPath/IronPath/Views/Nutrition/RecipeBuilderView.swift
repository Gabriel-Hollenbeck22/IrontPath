//
//  RecipeBuilderView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI
import SwiftData

struct RecipeBuilderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var recipeName = ""
    @State private var recipeDescription = ""
    @State private var servings = 1
    @State private var prepTime = ""
    @State private var ingredients: [RecipeIngredientEntry] = []
    @State private var showingFoodSearch = false
    @State private var editingIngredientIndex: Int?
    
    // For editing existing recipe
    var existingRecipe: Recipe?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.sectionSpacing) {
                    // Recipe Info
                    recipeInfoSection
                    
                    // Ingredients List
                    ingredientsSection
                    
                    // Nutrition Summary
                    if !ingredients.isEmpty {
                        nutritionSummarySection
                    }
                    
                    // Save Button
                    Button {
                        saveRecipe()
                    } label: {
                        Label("Save Recipe", systemImage: "checkmark.circle.fill")
                    }
                    .neonGlowButton(color: .ironPathSuccess)
                    .disabled(recipeName.isEmpty || ingredients.isEmpty)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.lg)
            }
            .navigationTitle(existingRecipe == nil ? "New Recipe" : "Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingFoodSearch) {
                RecipeIngredientSearchView { searchItem, amount in
                    addIngredient(searchItem: searchItem, amount: amount)
                }
            }
            .onAppear {
                loadExistingRecipe()
            }
        }
    }
    
    // MARK: - Recipe Info Section
    
    private var recipeInfoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Recipe Details")
                .font(.cardTitle)
            
            TextField("Recipe Name", text: $recipeName)
                .textFieldStyle(.roundedBorder)
            
            TextField("Description (optional)", text: $recipeDescription)
                .textFieldStyle(.roundedBorder)
            
            HStack(spacing: Spacing.lg) {
                VStack(alignment: .leading) {
                    Text("Servings")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Stepper("\(servings)", value: $servings, in: 1...20)
                }
                
                VStack(alignment: .leading) {
                    Text("Prep Time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    TextField("mins", text: $prepTime)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                }
            }
        }
        .premiumCard()
    }
    
    // MARK: - Ingredients Section
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Ingredients")
                    .font(.cardTitle)
                
                Spacer()
                
                Button {
                    showingFoodSearch = true
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                        .font(.subheadline.weight(.semibold))
                }
            }
            
            if ingredients.isEmpty {
                Text("No ingredients added yet")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(Array(ingredients.enumerated()), id: \.offset) { index, ingredient in
                    IngredientRow(
                        ingredient: ingredient,
                        onEdit: {
                            editingIngredientIndex = index
                        },
                        onDelete: {
                            ingredients.remove(at: index)
                        }
                    )
                }
            }
        }
        .premiumCard()
    }
    
    // MARK: - Nutrition Summary Section
    
    private var nutritionSummarySection: some View {
        let totals = calculateTotalMacros()
        let perServing = (
            calories: totals.calories / Double(servings),
            protein: totals.protein / Double(servings),
            carbs: totals.carbs / Double(servings),
            fat: totals.fat / Double(servings)
        )
        
        return VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Nutrition per Serving")
                .font(.cardTitle)
            
            HStack(spacing: Spacing.lg) {
                MacroColumn(label: "Calories", value: "\(Int(perServing.calories))", color: .primary)
                MacroColumn(label: "Protein", value: "\(Int(perServing.protein))g", color: Color.macroProtein)
                MacroColumn(label: "Carbs", value: "\(Int(perServing.carbs))g", color: .macroCarbs)
                MacroColumn(label: "Fat", value: "\(Int(perServing.fat))g", color: .macroFat)
            }
            
            Divider()
            
            Text("Total Recipe")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: Spacing.lg) {
                MacroColumn(label: "Calories", value: "\(Int(totals.calories))", color: .primary.opacity(0.6))
                MacroColumn(label: "Protein", value: "\(Int(totals.protein))g", color: Color.macroProtein.opacity(0.6))
                MacroColumn(label: "Carbs", value: "\(Int(totals.carbs))g", color: .macroCarbs.opacity(0.6))
                MacroColumn(label: "Fat", value: "\(Int(totals.fat))g", color: .macroFat.opacity(0.6))
            }
        }
        .accentCard()
    }
    
    // MARK: - Helper Methods
    
    private func calculateTotalMacros() -> (calories: Double, protein: Double, carbs: Double, fat: Double) {
        var calories = 0.0
        var protein = 0.0
        var carbs = 0.0
        var fat = 0.0
        
        for ingredient in ingredients {
            let multiplier = ingredient.amountGrams / 100.0
            calories += ingredient.caloriesPer100g * multiplier
            protein += ingredient.proteinPer100g * multiplier
            carbs += ingredient.carbsPer100g * multiplier
            fat += ingredient.fatPer100g * multiplier
        }
        
        return (calories, protein, carbs, fat)
    }
    
    private func addIngredient(searchItem: FoodSearchItem, amount: Double) {
        let entry = RecipeIngredientEntry(
            id: UUID(),
            name: searchItem.name,
            brand: searchItem.brand,
            amountGrams: amount,
            caloriesPer100g: searchItem.caloriesPer100g,
            proteinPer100g: searchItem.proteinPer100g,
            carbsPer100g: searchItem.carbsPer100g,
            fatPer100g: searchItem.fatPer100g,
            originalSearchItem: searchItem
        )
        ingredients.append(entry)
    }
    
    private func loadExistingRecipe() {
        guard let recipe = existingRecipe else { return }
        
        recipeName = recipe.name
        recipeDescription = recipe.recipeDescription ?? ""
        servings = recipe.servings
        prepTime = recipe.prepTimeMinutes.map { String($0) } ?? ""
        
        // Load ingredients
        if let recipeIngredients = recipe.ingredients {
            ingredients = recipeIngredients.compactMap { ingredient in
                guard let food = ingredient.foodItem else { return nil }
                return RecipeIngredientEntry(
                    id: ingredient.id,
                    name: food.name,
                    brand: food.brand,
                    amountGrams: ingredient.amountGrams,
                    caloriesPer100g: food.caloriesPer100g,
                    proteinPer100g: food.proteinPer100g,
                    carbsPer100g: food.carbsPer100g,
                    fatPer100g: food.fatPer100g,
                    originalSearchItem: FoodSearchItem(from: food)
                )
            }
        }
    }
    
    private func saveRecipe() {
        let recipe = existingRecipe ?? Recipe(name: recipeName)
        
        recipe.name = recipeName
        recipe.recipeDescription = recipeDescription.isEmpty ? nil : recipeDescription
        recipe.servings = servings
        recipe.prepTimeMinutes = Int(prepTime)
        recipe.lastUsed = Date()
        
        if existingRecipe == nil {
            modelContext.insert(recipe)
        }
        
        // Clear existing ingredients
        if let existingIngredients = recipe.ingredients {
            for ingredient in existingIngredients {
                modelContext.delete(ingredient)
            }
        }
        
        // Add new ingredients
        for entry in ingredients {
            // Create or fetch FoodItem
            let foodItem = createOrFetchFoodItem(from: entry)
            
            let ingredient = RecipeIngredient(amountGrams: entry.amountGrams)
            ingredient.foodItem = foodItem
            ingredient.recipe = recipe
            modelContext.insert(ingredient)
        }
        
        try? modelContext.save()
        HapticManager.success()
        dismiss()
    }
    
    private func createOrFetchFoodItem(from entry: RecipeIngredientEntry) -> FoodItem {
        // Try to find existing food item
        let nameToFind = entry.name
        let descriptor = FetchDescriptor<FoodItem>()
        
        if let existing = try? modelContext.fetch(descriptor).first(where: { $0.name == nameToFind }) {
            return existing
        }
        
        // Create new food item
        let foodItem = FoodItem(
            name: entry.name,
            brand: entry.brand,
            caloriesPer100g: entry.caloriesPer100g,
            proteinPer100g: entry.proteinPer100g,
            carbsPer100g: entry.carbsPer100g,
            fatPer100g: entry.fatPer100g,
            source: .manual
        )
        modelContext.insert(foodItem)
        return foodItem
    }
}

// MARK: - Recipe Ingredient Entry

struct RecipeIngredientEntry: Identifiable {
    let id: UUID
    let name: String
    let brand: String?
    var amountGrams: Double
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
    let originalSearchItem: FoodSearchItem
}

// MARK: - Ingredient Row

struct IngredientRow: View {
    let ingredient: RecipeIngredientEntry
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.name)
                    .font(.body)
                
                Text("\(Int(ingredient.amountGrams))g")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            let multiplier = ingredient.amountGrams / 100.0
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(ingredient.caloriesPer100g * multiplier)) cal")
                    .font(.subheadline)
                
                Text("\(Int(ingredient.proteinPer100g * multiplier))g protein")
                    .font(.caption)
                    .foregroundStyle(Color.macroProtein)
            }
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .nestedCard()
    }
}

// MARK: - Ingredient Search View

struct RecipeIngredientSearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let onSelect: (FoodSearchItem, Double) -> Void
    
    @State private var nutritionService: NutritionService?
    @State private var searchText = ""
    @State private var searchResults: [FoodSearchResult] = []
    @State private var isSearching = false
    @State private var selectedItem: FoodSearchItem?
    @State private var amount: Double = 100
    @State private var searchTask: Task<Void, Never>?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                TextField("Search foods...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                if let selected = selectedItem {
                    // Amount Selection
                    VStack(spacing: Spacing.md) {
                        Text(selected.name)
                            .font(.headline)
                        
                        HStack {
                            TextField("Amount", value: $amount, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                                .frame(width: 100)
                            
                            Text("grams")
                                .foregroundStyle(.secondary)
                        }
                        
                        Button {
                            onSelect(selected, amount)
                            dismiss()
                        } label: {
                            Label("Add Ingredient", systemImage: "plus.circle.fill")
                        }
                        .neonGlowButton()
                        
                        Button("Choose Different") {
                            selectedItem = nil
                        }
                        .foregroundStyle(.secondary)
                    }
                    .padding()
                    .premiumCard()
                    .padding()
                } else if isSearching {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(searchResults) { result in
                            Button {
                                selectedItem = result.searchItem
                                amount = 100
                            } label: {
                                FoodSearchItemRow(
                                    searchItem: result.searchItem,
                                    sourceLabel: result.sourceLabel
                                ) {}
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Add Ingredient")
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
            .onChange(of: searchText) { _, newValue in
                searchTask?.cancel()
                
                if newValue.count >= 2 {
                    searchTask = Task {
                        try? await Task.sleep(nanoseconds: 300_000_000)
                        if !Task.isCancelled {
                            await performSearch()
                        }
                    }
                } else {
                    searchResults = []
                }
            }
        }
    }
    
    @MainActor
    private func performSearch() async {
        guard let service = nutritionService, !searchText.isEmpty else { return }
        
        isSearching = true
        
        do {
            let results = try await service.searchFood(query: searchText)
            searchResults = results
            isSearching = false
        } catch {
            print("Search error: \(error)")
            isSearching = false
        }
    }
}

#Preview {
    RecipeBuilderView()
        .modelContainer(for: Recipe.self, inMemory: true)
}
