//
//  DashboardView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProfiles: [UserProfile]
    
    @State private var integrationEngine: IntegrationEngine?
    @State private var nutritionService: NutritionService?
    @State private var recoveryScore: Double = 0
    @State private var suggestions: [SmartSuggestion] = []
    @State private var todaysSummary: DailySummary?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.sectionSpacing) {
                    // Header
                    headerSection
                    
                    // Recovery Score
                    if let profile = userProfiles.first {
                        RecoveryScoreCard(
                            recoveryScore: recoveryScore,
                            profile: profile
                        )
                    }
                    
                    // Smart Suggestions
                    if !suggestions.isEmpty {
                        SuggestionCarousel(suggestions: suggestions)
                    }
                    
                    // Macro Progress
                    if let summary = todaysSummary, let profile = userProfiles.first {
                        MacroProgressSection(
                            summary: summary,
                            profile: profile
                        )
                    }
                    
                    // Quick Actions
                    QuickActionsSection()
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.lg)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .onAppear {
                setupServices()
                loadDashboardData()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(greeting)
                .font(.title)
                .foregroundStyle(.primary)
            
            Text(Date(), style: .date)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }
    
    private func setupServices() {
        integrationEngine = IntegrationEngine(modelContext: modelContext)
        nutritionService = NutritionService(modelContext: modelContext)
    }
    
    private func loadDashboardData() {
        guard let engine = integrationEngine,
              let service = nutritionService,
              let profile = userProfiles.first else {
            return
        }
        
        Task {
            // Get today's summary
            if let summary = try? service.getTodaysSummary() {
                todaysSummary = summary
            }
            
            // Calculate recovery score
            let score = engine.calculateRecoveryScore(
                for: Date(),
                profile: profile,
                sleepHours: todaysSummary?.sleepHours,
                proteinIntake: todaysSummary?.totalProtein,
                lastWorkoutDate: nil // TODO: Get from WorkoutManager
            )
            
            await MainActor.run {
                recoveryScore = score
            }
            
            // Generate suggestions
            let generatedSuggestions = try? await engine.generateSuggestions(profile: profile)
            await MainActor.run {
                suggestions = generatedSuggestions ?? []
            }
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: UserProfile.self, inMemory: true)
}

