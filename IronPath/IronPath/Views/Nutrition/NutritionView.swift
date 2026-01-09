//
//  NutritionView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI
import SwiftData

struct NutritionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    @State private var nutritionService: NutritionService?
    @State private var todaysSummary: DailySummary?
    @State private var showingSearch = false
    @State private var showingBarcodeScanner = false
    @State private var scannedFoodItem: FoodItem?
    
    private var userProfile: UserProfile? {
        userProfiles.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.sectionSpacing) {
                    // Today's Summary
                    if let summary = todaysSummary {
                        nutritionSummarySection(summary: summary)
                    }
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Daily Log
                    if let summary = todaysSummary, let foods = summary.loggedFoods, !foods.isEmpty {
                        dailyLogSection(foods: foods)
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.lg)
            }
            .navigationTitle("Nutrition")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSearch = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingSearch) {
                FoodSearchView()
            }
            .sheet(isPresented: $showingBarcodeScanner) {
                BarcodeScannerView { foodItem in
                    scannedFoodItem = foodItem
                }
            }
            .sheet(item: $scannedFoodItem) { foodItem in
                FoodDetailView(foodItem: foodItem)
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                setupService()
                loadTodaysData()
            }
        }
    }
    
    private func nutritionSummarySection(summary: DailySummary) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Today's Macros")
                .font(.headline)
            
            HStack(spacing: Spacing.lg) {
                MacroRingView(
                    current: summary.totalProtein,
                    target: userProfile?.targetProtein ?? 150.0,
                    color: .macroProtein,
                    label: "Protein"
                )
                
                MacroRingView(
                    current: summary.totalCarbs,
                    target: userProfile?.targetCarbs ?? 200.0,
                    color: .macroCarbs,
                    label: "Carbs"
                )
                
                MacroRingView(
                    current: summary.totalFat,
                    target: userProfile?.targetFat ?? 65.0,
                    color: .macroFat,
                    label: "Fat"
                )
            }
        }
        .padding(Spacing.cardPadding)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                Button(action: { showingSearch = true }) {
                    Label("Search Food", systemImage: "magnifyingglass")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.ironPathPrimary)
                        .cornerRadius(12)
                }
                
                Button(action: { showingBarcodeScanner = true }) {
                    Label("Scan", systemImage: "barcode.viewfinder")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.ironPathAccent)
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private func dailyLogSection(foods: [LoggedFood]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Today's Log")
                .font(.headline)
            
            ForEach(foods) { food in
                HStack {
                    VStack(alignment: .leading) {
                        Text(food.foodItem?.name ?? "Quick Meal")
                            .font(.body)
                        Text("\(FormatHelpers.macro(food.protein)) protein")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(FormatHelpers.calories(food.calories))
                        .font(.headline)
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
            }
        }
    }
    
    private func setupService() {
        nutritionService = NutritionService(modelContext: modelContext)
    }
    
    private func loadTodaysData() {
        guard let service = nutritionService else { return }
        if let summary = try? service.getTodaysSummary() {
            todaysSummary = summary
        }
    }
}

#Preview {
    NutritionView()
        .modelContainer(for: DailySummary.self, inMemory: true)
}

