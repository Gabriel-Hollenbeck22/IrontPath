//
//  ReportsView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI
import SwiftData

struct ReportsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedCategory: ReportCategory = .nutrition
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.sectionSpacing) {
                    // Category Picker
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ReportCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Report Cards based on category
                    switch selectedCategory {
                    case .nutrition:
                        nutritionReports
                    case .progress:
                        progressReports
                    case .body:
                        bodyReports
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.lg)
            }
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.large)
            .background(
                LinearGradient(
                    colors: [Color.subtleGradientTop, Color.subtleGradientBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    // MARK: - Nutrition Reports
    
    private var nutritionReports: some View {
        VStack(spacing: Spacing.md) {
            NavigationLink {
                CalorieReportView()
            } label: {
                ReportCard(
                    title: "Calorie Report",
                    subtitle: "Energy budget, consumed vs burned",
                    icon: "flame.fill",
                    color: .orange
                )
            }
            
            NavigationLink {
                CalorieHistoryChartView()
            } label: {
                ReportCard(
                    title: "Calorie History",
                    subtitle: "7 days, 2 weeks, or month view",
                    icon: "chart.xyaxis.line",
                    color: .blue
                )
            }
            
            NavigationLink {
                NutrientTargetsView()
            } label: {
                ReportCard(
                    title: "Nutrient Targets",
                    subtitle: "Macros, vitamins, minerals",
                    icon: "target",
                    color: .green
                )
            }
            
            NavigationLink {
                RecipeListView()
            } label: {
                ReportCard(
                    title: "My Recipes",
                    subtitle: "Custom meals and favorites",
                    icon: "book.fill",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Progress Reports
    
    private var progressReports: some View {
        VStack(spacing: Spacing.md) {
            NavigationLink {
                ExerciseProgressListView()
            } label: {
                ReportCard(
                    title: "Exercise Progress",
                    subtitle: "Track strength gains per exercise",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .ironPathPrimary
                )
            }
            
            NavigationLink {
                AnalyticsView()
            } label: {
                ReportCard(
                    title: "Analytics",
                    subtitle: "Correlations and insights",
                    icon: "chart.bar.fill",
                    color: .cyan
                )
            }
            
            NavigationLink {
                WorkoutHistoryView()
            } label: {
                ReportCard(
                    title: "Workout History",
                    subtitle: "All completed workouts",
                    icon: "clock.fill",
                    color: .orange
                )
            }
        }
    }
    
    // MARK: - Body Reports
    
    private var bodyReports: some View {
        VStack(spacing: Spacing.md) {
            NavigationLink {
                WeightTrackerView()
            } label: {
                ReportCard(
                    title: "Weight Tracker",
                    subtitle: "Track weight and body composition",
                    icon: "scalemass.fill",
                    color: .teal
                )
            }
            
            NavigationLink {
                // Future: Body measurements view
                Text("Coming Soon")
            } label: {
                ReportCard(
                    title: "Body Measurements",
                    subtitle: "Track muscle measurements",
                    icon: "ruler.fill",
                    color: .indigo,
                    isComingSoon: true
                )
            }
        }
    }
}

// MARK: - Report Category

enum ReportCategory: String, CaseIterable {
    case nutrition = "Nutrition"
    case progress = "Progress"
    case body = "Body"
    
    var icon: String {
        switch self {
        case .nutrition: return "fork.knife"
        case .progress: return "chart.line.uptrend.xyaxis"
        case .body: return "figure.stand"
        }
    }
}

// MARK: - Report Card

struct ReportCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var isComingSoon: Bool = false
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    if isComingSoon {
                        Text("Coming Soon")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .premiumCard()
        .opacity(isComingSoon ? 0.6 : 1)
    }
}

// MARK: - Recipe List View

struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Recipe.lastUsed, order: .reverse) private var recipes: [Recipe]
    
    @State private var showingRecipeBuilder = false
    
    var body: some View {
        List {
            if recipes.isEmpty {
                ContentUnavailableView(
                    "No Recipes Yet",
                    systemImage: "book.fill",
                    description: Text("Create your first custom recipe")
                )
            } else {
                ForEach(recipes) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipe: recipe)
                    } label: {
                        RecipeRow(recipe: recipe)
                    }
                }
                .onDelete(perform: deleteRecipes)
            }
        }
        .navigationTitle("My Recipes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingRecipeBuilder = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.ironPathPrimary)
                }
            }
        }
        .sheet(isPresented: $showingRecipeBuilder) {
            RecipeBuilderView()
        }
    }
    
    private func deleteRecipes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(recipes[index])
        }
        try? modelContext.save()
    }
}

// MARK: - Recipe Row

struct RecipeRow: View {
    let recipe: Recipe
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(recipe.name)
                        .font(.headline)
                    
                    if recipe.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                    }
                }
                
                Text("\(recipe.servings) serving\(recipe.servings > 1 ? "s" : "")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(recipe.macrosPerServing.calories)) cal")
                    .font(.subheadline.bold())
                
                Text("\(Int(recipe.macrosPerServing.protein))g protein")
                    .font(.caption)
                    .foregroundStyle(Color.macroProtein)
            }
        }
    }
}

// MARK: - Recipe Detail View

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let recipe: Recipe
    
    @State private var showingEditSheet = false
    @State private var servingsToLog = 1
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sectionSpacing) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text(recipe.name)
                            .font(.sectionTitle)
                        
                        Spacer()
                        
                        Button {
                            recipe.isFavorite.toggle()
                            try? modelContext.save()
                        } label: {
                            Image(systemName: recipe.isFavorite ? "star.fill" : "star")
                                .foregroundStyle(recipe.isFavorite ? .yellow : .secondary)
                        }
                    }
                    
                    if let description = recipe.recipeDescription {
                        Text(description)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: Spacing.md) {
                        Label("\(recipe.servings) servings", systemImage: "person.2.fill")
                        
                        if let prepTime = recipe.prepTimeMinutes {
                            Label("\(prepTime) min", systemImage: "clock.fill")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .premiumCard()
                
                // Nutrition per serving
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Per Serving")
                        .font(.cardTitle)
                    
                    let macros = recipe.macrosPerServing
                    HStack(spacing: Spacing.lg) {
                        MacroColumn(label: "Calories", value: "\(Int(macros.calories))", color: .primary)
                        MacroColumn(label: "Protein", value: "\(Int(macros.protein))g", color: .macroProtein)
                        MacroColumn(label: "Carbs", value: "\(Int(macros.carbs))g", color: .macroCarbs)
                        MacroColumn(label: "Fat", value: "\(Int(macros.fat))g", color: .macroFat)
                    }
                }
                .accentCard()
                
                // Ingredients
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Ingredients")
                        .font(.cardTitle)
                    
                    if let ingredients = recipe.ingredients, !ingredients.isEmpty {
                        ForEach(ingredients) { ingredient in
                            if let food = ingredient.foodItem {
                                HStack {
                                    Text(food.name)
                                        .font(.body)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(ingredient.amountGrams))g")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .nestedCard()
                            }
                        }
                    } else {
                        Text("No ingredients added")
                            .foregroundStyle(.secondary)
                    }
                }
                .premiumCard()
                
                // Log Recipe
                VStack(spacing: Spacing.md) {
                    Stepper("Log \(servingsToLog) serving\(servingsToLog > 1 ? "s" : "")", value: $servingsToLog, in: 1...10)
                    
                    Button {
                        logRecipe()
                    } label: {
                        Label("Log Recipe", systemImage: "plus.circle.fill")
                    }
                    .neonGlowButton()
                }
                .premiumCard()
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.lg)
        }
        .navigationTitle("Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingEditSheet = true
                } label: {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            RecipeBuilderView(existingRecipe: recipe)
        }
    }
    
    private func logRecipe() {
        let macros = recipe.macrosPerServing
        let totalCalories = macros.calories * Double(servingsToLog)
        let totalProtein = macros.protein * Double(servingsToLog)
        let totalCarbs = macros.carbs * Double(servingsToLog)
        let totalFat = macros.fat * Double(servingsToLog)
        
        // Create logged food entry
        let loggedFood = LoggedFood(
            servingSizeGrams: Double(servingsToLog) * 100, // Approximate serving size
            loggedAt: Date(),
            mealType: .snack,
            calories: totalCalories,
            protein: totalProtein,
            carbs: totalCarbs,
            fat: totalFat
        )
        loggedFood.recipe = recipe
        
        modelContext.insert(loggedFood)
        
        // Update recipe usage
        recipe.lastUsed = Date()
        recipe.useCount += 1
        
        try? modelContext.save()
        HapticManager.success()
        dismiss()
    }
}

#Preview {
    ReportsView()
        .modelContainer(for: [DailySummary.self, Recipe.self], inMemory: true)
}
