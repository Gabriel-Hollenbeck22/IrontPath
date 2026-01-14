//
//  NotificationManager.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import Foundation
import UserNotifications

@Observable
final class NotificationManager {
    
    // MARK: - Properties
    
    var isAuthorized = false
    
    // Notification identifiers
    private enum NotificationID {
        static let streakReminder = "ironpath.streak.reminder"
        static let mealReminder = "ironpath.meal.reminder"
        static let workoutSuggestion = "ironpath.workout.suggestion"
        static let restDay = "ironpath.rest.day"
    }
    
    // MARK: - Initialization
    
    init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    /// Check current notification authorization status
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    /// Request notification authorization
    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            
            await MainActor.run {
                isAuthorized = granted
            }
            
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    /// Get current notification settings
    func getNotificationSettings() async -> UNNotificationSettings {
        await UNUserNotificationCenter.current().notificationSettings()
    }
    
    // MARK: - Streak Reminders
    
    /// Schedule a streak reminder notification
    func scheduleStreakReminder(currentStreak: Int, at hour: Int = 20, minute: Int = 0) {
        guard isAuthorized else { return }
        
        // Cancel existing streak reminders
        cancelNotifications(withIdentifier: NotificationID.streakReminder)
        
        let content = UNMutableNotificationContent()
        
        if currentStreak > 0 {
            content.title = "Don't Break Your Streak! 🔥"
            content.body = "You have a \(currentStreak)-day streak! Log your workout or meal to keep it going."
        } else {
            content.title = "Start a New Streak! 💪"
            content.body = "Log a workout or meal today to begin building your streak."
        }
        
        content.sound = .default
        content.categoryIdentifier = "STREAK_REMINDER"
        
        // Schedule for specified time daily
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: NotificationID.streakReminder,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling streak reminder: \(error)")
            }
        }
    }
    
    // MARK: - Meal Reminders
    
    /// Schedule meal logging reminders
    func scheduleMealReminder(mealType: MealType, at hour: Int, minute: Int = 0) {
        guard isAuthorized else { return }
        
        let identifier = "\(NotificationID.mealReminder).\(mealType.rawValue)"
        
        // Cancel existing reminder for this meal
        cancelNotifications(withIdentifier: identifier)
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Log \(mealType.displayName)! 🍽️"
        content.body = "Track your \(mealType.displayName.lowercased()) to stay on top of your nutrition goals."
        content.sound = .default
        content.categoryIdentifier = "MEAL_REMINDER"
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling meal reminder: \(error)")
            }
        }
    }
    
    /// Cancel meal reminder for a specific meal type
    func cancelMealReminder(mealType: MealType) {
        let identifier = "\(NotificationID.mealReminder).\(mealType.rawValue)"
        cancelNotifications(withIdentifier: identifier)
    }
    
    // MARK: - Workout Suggestions
    
    /// Schedule a workout suggestion notification
    func scheduleWorkoutSuggestion(
        message: String,
        delay: TimeInterval = 3600 // 1 hour default
    ) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Workout Suggestion 💡"
        content.body = message
        content.sound = .default
        content.categoryIdentifier = "WORKOUT_SUGGESTION"
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: delay,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "\(NotificationID.workoutSuggestion).\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling workout suggestion: \(error)")
            }
        }
    }
    
    // MARK: - Rest Day Reminders
    
    /// Schedule rest day recommendation
    func scheduleRestDayReminder(at hour: Int = 9, minute: Int = 0) {
        guard isAuthorized else { return }
        
        // Cancel existing rest day reminders
        cancelNotifications(withIdentifier: NotificationID.restDay)
        
        let content = UNMutableNotificationContent()
        content.title = "Rest Day Reminder 😴"
        content.body = "Recovery is part of progress! Consider taking it easy today to let your muscles rebuild."
        content.sound = .default
        content.categoryIdentifier = "REST_DAY"
        
        // Schedule for tomorrow at specified time
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: NotificationID.restDay,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling rest day reminder: \(error)")
            }
        }
    }
    
    // MARK: - Cancel Notifications
    
    /// Cancel notifications with a specific identifier prefix
    func cancelNotifications(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToRemove = requests
                .filter { $0.identifier.hasPrefix(identifier) }
                .map { $0.identifier }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(
                withIdentifiers: identifiersToRemove
            )
        }
    }
    
    /// Cancel all IronPath notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Badge Management
    
    /// Clear the app badge
    func clearBadge() {
        Task { @MainActor in
            UNUserNotificationCenter.current().setBadgeCount(0)
        }
    }
}

// MARK: - Meal Type Extension

extension MealType {
    /// Default reminder time for this meal type
    var defaultReminderHour: Int {
        switch self {
        case .breakfast: return 8
        case .lunch: return 12
        case .dinner: return 18
        case .snack: return 15
        case .preworkout: return 16
        case .postworkout: return 18
        }
    }
}
