//
//  NotificationSettingsView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI

struct NotificationSettingsView: View {
    @State private var notificationManager = NotificationManager()
    @State private var isAuthorized = false
    @State private var isRequesting = false
    
    // Streak Reminders
    @AppStorage("notifications_streak_enabled") private var streakEnabled = true
    @AppStorage("notifications_streak_hour") private var streakHour = 20
    @AppStorage("notifications_streak_minute") private var streakMinute = 0
    
    // Meal Reminders
    @AppStorage("notifications_breakfast_enabled") private var breakfastEnabled = false
    @AppStorage("notifications_breakfast_hour") private var breakfastHour = 8
    @AppStorage("notifications_lunch_enabled") private var lunchEnabled = false
    @AppStorage("notifications_lunch_hour") private var lunchHour = 12
    @AppStorage("notifications_dinner_enabled") private var dinnerEnabled = false
    @AppStorage("notifications_dinner_hour") private var dinnerHour = 18
    
    // Workout Suggestions
    @AppStorage("notifications_workout_enabled") private var workoutEnabled = true
    
    // Rest Day
    @AppStorage("notifications_rest_enabled") private var restEnabled = true
    
    private var streakTime: Date {
        var components = DateComponents()
        components.hour = streakHour
        components.minute = streakMinute
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var body: some View {
        List {
            // Authorization Section
            Section {
                HStack(spacing: Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(isAuthorized ? Color.ironPathSuccess.opacity(0.15) : Color.orange.opacity(0.15))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: isAuthorized ? "bell.badge.fill" : "bell.slash.fill")
                            .font(.title2)
                            .foregroundStyle(isAuthorized ? Color.ironPathSuccess : .orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isAuthorized ? "Notifications Enabled" : "Notifications Disabled")
                            .font(.headline)
                        
                        Text(isAuthorized ? "You'll receive reminders and suggestions" : "Enable to receive helpful reminders")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if !isAuthorized && !isRequesting {
                        Button("Enable") {
                            requestAuthorization()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.ironPathPrimary)
                    } else if isRequesting {
                        ProgressView()
                    }
                }
            }
            
            if isAuthorized {
                // Streak Reminders
                Section {
                    Toggle(isOn: $streakEnabled) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Streak Reminders")
                                Text("Daily reminder to maintain your streak")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                    .onChange(of: streakEnabled) { _, enabled in
                        updateStreakNotification(enabled: enabled)
                    }
                    
                    if streakEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: Binding(
                                get: { streakTime },
                                set: { newTime in
                                    let components = Calendar.current.dateComponents([.hour, .minute], from: newTime)
                                    streakHour = components.hour ?? 20
                                    streakMinute = components.minute ?? 0
                                    updateStreakNotification(enabled: true)
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                    }
                } header: {
                    Text("Streaks")
                }
                
                // Meal Reminders
                Section {
                    MealReminderToggle(
                        mealType: .breakfast,
                        isEnabled: $breakfastEnabled,
                        hour: $breakfastHour
                    )
                    
                    MealReminderToggle(
                        mealType: .lunch,
                        isEnabled: $lunchEnabled,
                        hour: $lunchHour
                    )
                    
                    MealReminderToggle(
                        mealType: .dinner,
                        isEnabled: $dinnerEnabled,
                        hour: $dinnerHour
                    )
                } header: {
                    Text("Meal Logging")
                } footer: {
                    Text("Get reminders to log your meals and stay on track with your nutrition goals.")
                }
                
                // Other Notifications
                Section {
                    Toggle(isOn: $workoutEnabled) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Workout Suggestions")
                                Text("Smart recommendations based on your progress")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(.yellow)
                        }
                    }
                    
                    Toggle(isOn: $restEnabled) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Rest Day Reminders")
                                Text("Recovery recommendations when needed")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "bed.double.fill")
                                .foregroundStyle(.indigo)
                        }
                    }
                } header: {
                    Text("Training")
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isAuthorized = notificationManager.isAuthorized
        }
    }
    
    // MARK: - Actions
    
    private func requestAuthorization() {
        isRequesting = true
        
        Task {
            let granted = await notificationManager.requestAuthorization()
            
            await MainActor.run {
                isAuthorized = granted
                isRequesting = false
                
                if granted {
                    HapticManager.success()
                    // Set up default notifications
                    if streakEnabled {
                        updateStreakNotification(enabled: true)
                    }
                }
            }
        }
    }
    
    private func updateStreakNotification(enabled: Bool) {
        if enabled {
            notificationManager.scheduleStreakReminder(
                currentStreak: 0, // Will be updated from StreakCard
                at: streakHour,
                minute: streakMinute
            )
        } else {
            notificationManager.cancelNotifications(withIdentifier: "ironpath.streak.reminder")
        }
    }
}

// MARK: - Meal Reminder Toggle

struct MealReminderToggle: View {
    let mealType: MealType
    @Binding var isEnabled: Bool
    @Binding var hour: Int
    
    @State private var notificationManager = NotificationManager()
    
    private var mealTime: Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Toggle(isOn: $isEnabled) {
                Label(mealType.displayName, systemImage: iconForMeal)
                    .foregroundStyle(iconColorForMeal)
            }
            .onChange(of: isEnabled) { _, enabled in
                updateMealNotification(enabled: enabled)
            }
            
            if isEnabled {
                DatePicker(
                    "Time",
                    selection: Binding(
                        get: { mealTime },
                        set: { newTime in
                            let components = Calendar.current.dateComponents([.hour], from: newTime)
                            hour = components.hour ?? mealType.defaultReminderHour
                            updateMealNotification(enabled: true)
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .padding(.leading, 44)
            }
        }
    }
    
    private var iconForMeal: String {
        switch mealType {
        case .breakfast: return "sun.horizon.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.fill"
        case .snack: return "carrot.fill"
        case .preworkout: return "bolt.fill"
        case .postworkout: return "figure.cooldown"
        }
    }
    
    private var iconColorForMeal: Color {
        switch mealType {
        case .breakfast: return .orange
        case .lunch: return .yellow
        case .dinner: return .indigo
        case .snack: return .green
        case .preworkout: return .cyan
        case .postworkout: return .teal
        }
    }
    
    private func updateMealNotification(enabled: Bool) {
        if enabled {
            notificationManager.scheduleMealReminder(mealType: mealType, at: hour)
        } else {
            notificationManager.cancelMealReminder(mealType: mealType)
        }
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}
