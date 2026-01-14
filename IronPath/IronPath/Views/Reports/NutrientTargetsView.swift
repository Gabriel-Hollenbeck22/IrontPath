//
//  NutrientTargetsView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI
import SwiftData

struct NutrientTargetsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \DailySummary.date, order: .reverse) private var summaries: [DailySummary]
    @Query private var profiles: [UserProfile]
    
    @State private var selectedCategory: NutrientCategory = .macros
    
    private var profile: UserProfile? { profiles.first }
    private var todaysSummary: DailySummary? {
        summaries.first { Calendar.current.isDateInToday($0.date) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.sectionSpacing) {
                // Category Picker
                categoryPicker
                
                // Content based on category
                switch selectedCategory {
                case .macros:
                    macroTargetsSection
                case .vitamins:
                    vitaminTargetsSection
                case .minerals:
                    mineralTargetsSection
                case .fats:
                    fatTargetsSection
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.lg)
        }
        .navigationTitle("Nutrient Targets")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            LinearGradient(
                colors: [Color.subtleGradientTop, Color.subtleGradientBottom],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Category Picker
    
    private var categoryPicker: some View {
        Picker("Category", selection: $selectedCategory) {
            ForEach(NutrientCategory.allCases, id: \.self) { category in
                Text(category.rawValue).tag(category)
            }
        }
        .pickerStyle(.segmented)
    }
    
    // MARK: - Macro Targets Section
    
    private var macroTargetsSection: some View {
        let summary = todaysSummary
        let targetProtein = profile?.targetProtein ?? 150
        let targetCarbs = profile?.targetCarbs ?? 200
        let targetFat = profile?.targetFat ?? 65
        let targetCalories = profile?.targetCalories ?? 2000
        
        return VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Macronutrient Targets")
                .font(.cardTitle)
            
            NutrientProgressRow(
                name: "Calories",
                current: summary?.totalCalories ?? 0,
                target: targetCalories,
                unit: "cal",
                color: .primary,
                showPercentage: true
            )
            
            NutrientProgressRow(
                name: "Protein",
                current: summary?.totalProtein ?? 0,
                target: targetProtein,
                unit: "g",
                color: .macroProtein,
                showPercentage: true
            )
            
            NutrientProgressRow(
                name: "Carbohydrates",
                current: summary?.totalCarbs ?? 0,
                target: targetCarbs,
                unit: "g",
                color: .macroCarbs,
                showPercentage: true
            )
            
            NutrientProgressRow(
                name: "Fat",
                current: summary?.totalFat ?? 0,
                target: targetFat,
                unit: "g",
                color: .macroFat,
                showPercentage: true
            )
            
            // Fiber (if tracked)
            NutrientProgressRow(
                name: "Fiber",
                current: 0, // Would come from daily summary when tracked
                target: profile?.biologicalSex == .male ? 38 : 25,
                unit: "g",
                color: .green,
                showPercentage: true
            )
        }
        .premiumCard()
    }
    
    // MARK: - Vitamin Targets Section
    
    private var vitaminTargetsSection: some View {
        let rdas = getRDAs()
        
        return VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Vitamin Targets")
                .font(.cardTitle)
            
            // Fat-soluble vitamins
            Group {
                Text("Fat-Soluble Vitamins")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, Spacing.sm)
                
                NutrientProgressRow(
                    name: "Vitamin A",
                    current: 0,
                    target: rdas["vitaminA"]?.target ?? 900,
                    unit: "mcg",
                    color: .orange,
                    showPercentage: true
                )
                
                NutrientProgressRow(
                    name: "Vitamin D",
                    current: 0,
                    target: rdas["vitaminD"]?.target ?? 15,
                    unit: "mcg",
                    color: .yellow,
                    showPercentage: true
                )
                
                NutrientProgressRow(
                    name: "Vitamin E",
                    current: 0,
                    target: rdas["vitaminE"]?.target ?? 15,
                    unit: "mg",
                    color: .green,
                    showPercentage: true
                )
                
                NutrientProgressRow(
                    name: "Vitamin K",
                    current: 0,
                    target: rdas["vitaminK"]?.target ?? 120,
                    unit: "mcg",
                    color: .mint,
                    showPercentage: true
                )
            }
            
            // Water-soluble vitamins
            Group {
                Text("Water-Soluble Vitamins")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, Spacing.sm)
                
                NutrientProgressRow(
                    name: "Vitamin C",
                    current: 0,
                    target: rdas["vitaminC"]?.target ?? 90,
                    unit: "mg",
                    color: .orange,
                    showPercentage: true
                )
                
                NutrientProgressRow(
                    name: "Thiamin (B1)",
                    current: 0,
                    target: rdas["vitaminB1"]?.target ?? 1.2,
                    unit: "mg",
                    color: .blue,
                    showPercentage: true
                )
                
                NutrientProgressRow(
                    name: "Riboflavin (B2)",
                    current: 0,
                    target: rdas["vitaminB2"]?.target ?? 1.3,
                    unit: "mg",
                    color: .blue,
                    showPercentage: true
                )
                
                NutrientProgressRow(
                    name: "Niacin (B3)",
                    current: 0,
                    target: rdas["vitaminB3"]?.target ?? 16,
                    unit: "mg",
                    color: .blue,
                    showPercentage: true
                )
                
                NutrientProgressRow(
                    name: "Pyridoxine (B6)",
                    current: 0,
                    target: rdas["vitaminB6"]?.target ?? 1.3,
                    unit: "mg",
                    color: .blue,
                    showPercentage: true
                )
                
                NutrientProgressRow(
                    name: "Folate (B9)",
                    current: 0,
                    target: rdas["vitaminB9"]?.target ?? 400,
                    unit: "mcg",
                    color: .blue,
                    showPercentage: true
                )
                
                NutrientProgressRow(
                    name: "Cobalamin (B12)",
                    current: 0,
                    target: rdas["vitaminB12"]?.target ?? 2.4,
                    unit: "mcg",
                    color: .blue,
                    showPercentage: true
                )
            }
        }
        .premiumCard()
    }
    
    // MARK: - Mineral Targets Section
    
    private var mineralTargetsSection: some View {
        let rdas = getRDAs()
        
        return VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Mineral Targets")
                .font(.cardTitle)
            
            // Major minerals
            Group {
                Text("Major Minerals")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, Spacing.sm)
                
                NutrientProgressRow(
                    name: "Calcium",
                    current: 0,
                    target: rdas["calcium"]?.target ?? 1000,
                    unit: "mg",
                    color: .white,
                    showPercentage: true
                )
                
                NutrientProgressRow(
                    name: "Magnesium",
                    current: 0,
                    target: rdas["magnesium"]?.target ?? 400,
                    unit: "mg",
                    color: .purple,
                    showPercentage: true
                )
                
                NutrientProgressRow(
                    name: "Phosphorus",
                    current: 0,
                    target: rdas["phosphorus"]?.target ?? 700,
                    unit: "mg",
                    color: .orange,
                    showPercentage: true
                )
                
                NutrientProgressRow(
                    name: "Potassium",
                    current: 0,
                    target: rdas["potassium"]?.target ?? 3400,
                    unit: "mg",
                    color: .cyan,
                    showPercentage: true
                )
                
                NutrientProgressRow(
                    name: "Sodium",
                    current: 0,
                    target: rdas["sodium"]?.target ?? 1500,
                    unit: "mg",
                    color: .gray,
                    showPercentage: true,
                    isUpperLimit: true
                )
            }
            
            // Trace minerals
            Group {
                Text("Trace Minerals")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, Spacing.sm)
                
                NutrientProgressRow(
                    name: "Iron",
                    current: 0,
                    target: rdas["iron"]?.target ?? 8,
                    unit: "mg",
                    color: .red,
                    showPercentage: true
                )
                
                NutrientProgressRow(
                    name: "Zinc",
                    current: 0,
                    target: rdas["zinc"]?.target ?? 11,
                    unit: "mg",
                    color: .teal,
                    showPercentage: true
                )
                
                NutrientProgressRow(
                    name: "Selenium",
                    current: 0,
                    target: rdas["selenium"]?.target ?? 55,
                    unit: "mcg",
                    color: .brown,
                    showPercentage: true
                )
                
                NutrientProgressRow(
                    name: "Copper",
                    current: 0,
                    target: rdas["copper"]?.target ?? 0.9,
                    unit: "mg",
                    color: .orange,
                    showPercentage: true
                )
            }
        }
        .premiumCard()
    }
    
    // MARK: - Fat Targets Section
    
    private var fatTargetsSection: some View {
        let targetFat = profile?.targetFat ?? 65
        let targetSaturated = targetFat * 0.3  // Max 30% from saturated
        let targetOmega3 = 1.6  // 1.6g for males, 1.1g for females
        
        return VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Fat Quality Targets")
                .font(.cardTitle)
            
            NutrientProgressRow(
                name: "Total Fat",
                current: todaysSummary?.totalFat ?? 0,
                target: targetFat,
                unit: "g",
                color: .macroFat,
                showPercentage: true
            )
            
            NutrientProgressRow(
                name: "Saturated Fat",
                current: 0,
                target: targetSaturated,
                unit: "g",
                color: .red,
                showPercentage: true,
                isUpperLimit: true
            )
            
            NutrientProgressRow(
                name: "Trans Fat",
                current: 0,
                target: 2,
                unit: "g",
                color: .red,
                showPercentage: true,
                isUpperLimit: true
            )
            
            NutrientProgressRow(
                name: "Omega-3",
                current: 0,
                target: targetOmega3,
                unit: "g",
                color: .blue,
                showPercentage: true
            )
            
            NutrientProgressRow(
                name: "Cholesterol",
                current: 0,
                target: 300,
                unit: "mg",
                color: .yellow,
                showPercentage: true,
                isUpperLimit: true
            )
        }
        .premiumCard()
    }
    
    // MARK: - Helper Methods
    
    private func getRDAs() -> [String: NutrientRDA] {
        if profile?.biologicalSex == .female {
            return NutrientRDA.adultFemale
        }
        return NutrientRDA.adultMale
    }
}

// MARK: - Nutrient Category

enum NutrientCategory: String, CaseIterable {
    case macros = "Macros"
    case vitamins = "Vitamins"
    case minerals = "Minerals"
    case fats = "Fats"
}

// MARK: - Nutrient Progress Row

struct NutrientProgressRow: View {
    let name: String
    let current: Double
    let target: Double
    let unit: String
    let color: Color
    let showPercentage: Bool
    var isUpperLimit: Bool = false
    
    private var percentage: Double {
        guard target > 0 else { return 0 }
        return current / target
    }
    
    private var status: NutrientStatus {
        NutrientStatus.calculate(current: current, target: target, upperLimit: isUpperLimit ? target : nil)
    }
    
    private var statusColor: Color {
        if isUpperLimit {
            return percentage > 1 ? .ironPathError : .ironPathSuccess
        }
        
        switch status {
        case .deficient:
            return .ironPathError
        case .low:
            return .orange
        case .adequate, .optimal:
            return .ironPathSuccess
        case .high, .excess:
            return isUpperLimit ? .ironPathError : .blue
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                    
                    Text(name)
                        .font(.subheadline)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(formatValue(current))
                        .font(.subheadline.bold())
                    
                    Text("/")
                        .foregroundStyle(.secondary)
                    
                    Text("\(formatValue(target)) \(unit)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(statusColor)
                        .frame(width: min(CGFloat(percentage), 1.2) * geometry.size.width)
                }
            }
            .frame(height: 6)
            
            if showPercentage {
                HStack {
                    Text(isUpperLimit ? "Limit" : "Goal")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(percentage * 100))%")
                        .font(.caption2.bold())
                        .foregroundStyle(statusColor)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatValue(_ value: Double) -> String {
        if value < 10 {
            return String(format: "%.1f", value)
        }
        return "\(Int(value))"
    }
}

#Preview {
    NavigationStack {
        NutrientTargetsView()
    }
    .modelContainer(for: DailySummary.self, inMemory: true)
}
