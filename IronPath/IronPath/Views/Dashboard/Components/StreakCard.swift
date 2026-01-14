//
//  StreakCard.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI
import SwiftData

struct StreakCard: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var streakData: [StreakData]
    
    @State private var notificationManager = NotificationManager()
    @AppStorage("notifications_streak_enabled") private var streakNotificationsEnabled = true
    @AppStorage("notifications_streak_hour") private var streakHour = 20
    @AppStorage("notifications_streak_minute") private var streakMinute = 0
    @AppStorage("lastCelebratedMilestone") private var lastCelebratedMilestone = 0
    
    @State private var showCelebration = false
    @State private var celebrationMilestone: Int = 0
    
    private var streak: StreakData? { streakData.first }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Streaks")
                    .font(.cardTitle)
                
                Spacer()
                
                // Current milestone badge
                if let current = streak, let milestone = StreakMilestone.currentMilestone(for: max(current.currentWorkoutStreak, current.currentNutritionStreak)) {
                    Label(milestone.name, systemImage: milestone.icon)
                        .font(.caption)
                        .foregroundStyle(Color.ironPathPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.ironPathPrimary.opacity(0.15))
                        .cornerRadius(12)
                }
            }
            
            HStack(spacing: Spacing.lg) {
                // Workout Streak
                StreakItem(
                    icon: "flame.fill",
                    count: streak?.currentWorkoutStreak ?? 0,
                    label: "Workout",
                    color: .orange,
                    best: streak?.longestWorkoutStreak ?? 0
                )
                
                // Nutrition Streak
                StreakItem(
                    icon: "leaf.fill",
                    count: streak?.currentNutritionStreak ?? 0,
                    label: "Nutrition",
                    color: .green,
                    best: streak?.longestNutritionStreak ?? 0
                )
                
                // Combined Streak
                StreakItem(
                    icon: "star.fill",
                    count: streak?.currentCombinedStreak ?? 0,
                    label: "Combined",
                    color: .ironPathPrimary,
                    best: streak?.longestCombinedStreak ?? 0
                )
            }
            
            // Next milestone progress
            if let current = streak {
                let maxStreak = max(current.currentWorkoutStreak, current.currentNutritionStreak)
                if let nextMilestone = StreakMilestone.nextMilestone(for: maxStreak) {
                    NextMilestoneProgress(
                        currentStreak: maxStreak,
                        milestone: nextMilestone
                    )
                }
            }
            
            // Grace period indicator
            if let current = streak, current.isGracePeriodActive {
                HStack(spacing: 4) {
                    Image(systemName: "shield.fill")
                        .foregroundStyle(.yellow)
                    
                    Text("Grace period active - don't break your streak!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, Spacing.xs)
            }
        }
        .accentCard()
        .onAppear {
            ensureStreakDataExists()
            checkForNewMilestone()
        }
        .celebrationOverlay(
            isPresented: $showCelebration,
            type: .streakMilestone(days: celebrationMilestone)
        )
    }
    
    private func ensureStreakDataExists() {
        if streakData.isEmpty {
            let newStreak = StreakData()
            modelContext.insert(newStreak)
            try? modelContext.save()
        } else {
            // Check and update streak status
            streak?.checkStreakStatus()
            try? modelContext.save()
        }
        
        // Update streak notifications with current streak count
        updateStreakNotification()
    }
    
    private func updateStreakNotification() {
        guard streakNotificationsEnabled, notificationManager.isAuthorized else { return }
        
        let currentStreak = max(streak?.currentWorkoutStreak ?? 0, streak?.currentNutritionStreak ?? 0)
        notificationManager.scheduleStreakReminder(
            currentStreak: currentStreak,
            at: streakHour,
            minute: streakMinute
        )
    }
    
    private func checkForNewMilestone() {
        let currentStreak = max(streak?.currentWorkoutStreak ?? 0, streak?.currentNutritionStreak ?? 0)
        
        // Check if we hit a new milestone
        let milestones = [7, 14, 30, 60, 100, 365]
        for milestone in milestones {
            if currentStreak >= milestone && lastCelebratedMilestone < milestone {
                // New milestone reached!
                celebrationMilestone = milestone
                lastCelebratedMilestone = milestone
                
                // Delay showing celebration slightly for better UX
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showCelebration = true
                }
                break
            }
        }
    }
}

// MARK: - Streak Item

struct StreakItem: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color
    let best: Int
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
            }
            
            Text("\(count)")
                .font(.title3.bold())
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            if best > 0 {
                Text("Best: \(best)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Next Milestone Progress

struct NextMilestoneProgress: View {
    let currentStreak: Int
    let milestone: StreakMilestone
    
    private var progress: Double {
        let previousMilestone = StreakMilestone.milestones.last { $0.days < milestone.days }?.days ?? 0
        let range = milestone.days - previousMilestone
        let current = currentStreak - previousMilestone
        return Double(current) / Double(range)
    }
    
    private var daysRemaining: Int {
        milestone.days - currentStreak
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: milestone.icon)
                    .foregroundStyle(Color.ironPathPrimary)
                
                Text("Next: \(milestone.name)")
                    .font(.caption)
                
                Spacer()
                
                Text("\(daysRemaining) days to go")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.ironPathPrimary, .ironPathAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 6)
        }
        .padding(.top, Spacing.sm)
    }
}

// MARK: - Compact Streak View (for dashboard header)

struct CompactStreakView: View {
    let workoutStreak: Int
    let nutritionStreak: Int
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("\(workoutStreak)")
                    .font(.subheadline.bold())
            }
            
            HStack(spacing: 4) {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(.green)
                Text("\(nutritionStreak)")
                    .font(.subheadline.bold())
            }
        }
    }
}

#Preview {
    StreakCard()
        .padding()
        .modelContainer(for: StreakData.self, inMemory: true)
}
