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
    @Query(
        filter: #Predicate<Workout> { $0.isCompleted },
        sort: [SortDescriptor(\.date, order: .reverse)]
    ) private var completedWorkouts: [Workout]
    
    @State private var integrationEngine: IntegrationEngine?
    @State private var nutritionService: NutritionService?
    @State private var healthKitManager: HealthKitManager?
    @State private var recoveryScore: Double = 0
    @State private var suggestions: [SmartSuggestion] = []
    @State private var todaysSummary: DailySummary?
    
    @Binding var selectedTab: Int?
    
    private var lastWorkoutDate: Date? {
        completedWorkouts.first?.date
    }
    
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
                            profile: profile,
                            sleepHours: todaysSummary?.sleepHours,
                            proteinIntake: todaysSummary?.totalProtein
                        )
                    }
                    
                    // Streaks Card
                    StreakCard()
                    
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
                    QuickActionsSection(selectedTab: $selectedTab)  // Pass binding
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.lg)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .background(
                LinearGradient(
                    colors: [Color.subtleGradientTop, Color.subtleGradientBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .onAppear {
                setupServices()
                loadDashboardData()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(greeting)
                .font(.sectionTitle)
                .foregroundStyle(.primary)
            
            Text(Date(), style: .date)
                .font(.emphasizedCallout)
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
        healthKitManager = HealthKitManager()
        
        // Sync HealthKit data
        Task {
            try? await healthKitManager?.syncTodaysData()
            await MainActor.run {
                loadDashboardData()  // Reload after sync
            }
        }
    }
    
    private func loadDashboardData() {
        guard let engine = integrationEngine,
              let service = nutritionService,
              let profile = userProfiles.first else {
            return
        }
        
        Task {
            // Get today's summary
            let summary = try? service.getTodaysSummary()
            
            await MainActor.run {
                todaysSummary = summary
            }
            
            // Calculate recovery score
            let lastWorkout = await MainActor.run {
                lastWorkoutDate
            }
            
            let score = engine.calculateRecoveryScore(
                for: Date(),
                profile: profile,
                sleepHours: summary?.sleepHours,
                proteinIntake: summary?.totalProtein,
                lastWorkoutDate: lastWorkout
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
    DashboardView(selectedTab: .constant(nil))
        .modelContainer(for: UserProfile.self, inMemory: true)
}

