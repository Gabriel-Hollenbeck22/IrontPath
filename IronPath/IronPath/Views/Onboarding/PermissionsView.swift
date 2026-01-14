//
//  PermissionsView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI
import HealthKit

struct PermissionsView: View {
    let onComplete: () -> Void
    
    @State private var healthKitStatus: PermissionStatus = .notDetermined
    @State private var notificationStatus: PermissionStatus = .notDetermined
    @State private var contentOpacity: Double = 0
    @State private var isLoading = false
    
    private let healthKitManager = HealthKitManager()
    private let notificationManager = NotificationManager()
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Header
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.ironPathPrimary.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.ironPathPrimary)
                }
                
                Text("Final Step")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("Connect your health data for the best experience")
                    .font(.body)
                    .foregroundStyle(Color.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            
            // Permission cards
            VStack(spacing: 16) {
                PermissionCard(
                    icon: "heart.fill",
                    iconColor: .red,
                    title: "Apple Health",
                    description: "Sync weight, sleep, and activity data",
                    status: healthKitStatus,
                    onEnable: requestHealthKit
                )
                
                PermissionCard(
                    icon: "bell.fill",
                    iconColor: .orange,
                    title: "Notifications",
                    description: "Get streak reminders and workout prompts",
                    status: notificationStatus,
                    onEnable: requestNotifications
                )
            }
            
            Spacer()
            
            // Complete button
            VStack(spacing: 12) {
                Button(action: {
                    HapticManager.success()
                    onComplete()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Start Your Journey")
                                .font(.headline)
                            Image(systemName: "arrow.right")
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color.ironPathPrimary, Color.ironPathPrimary.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.ironPathPrimary.opacity(0.4), radius: 15, x: 0, y: 8)
                }
                .disabled(isLoading)
                
                Button("Skip for now") {
                    HapticManager.lightImpact()
                    onComplete()
                }
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.5))
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .opacity(contentOpacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                contentOpacity = 1.0
            }
            checkCurrentPermissions()
        }
    }
    
    // MARK: - Permission Requests
    
    private func requestHealthKit() {
        Task {
            isLoading = true
            do {
                try await healthKitManager.requestAuthorization()
                await MainActor.run {
                    healthKitStatus = .authorized
                    HapticManager.success()
                }
            } catch {
                await MainActor.run {
                    healthKitStatus = .denied
                    HapticManager.error()
                }
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    private func requestNotifications() {
        Task {
            isLoading = true
            let granted = await notificationManager.requestAuthorization()
            await MainActor.run {
                notificationStatus = granted ? .authorized : .denied
                if granted {
                    HapticManager.success()
                } else {
                    HapticManager.error()
                }
                isLoading = false
            }
        }
    }
    
    private func checkCurrentPermissions() {
        // Check HealthKit
        if HKHealthStore.isHealthDataAvailable() {
            // We'll treat it as not determined initially
            healthKitStatus = .notDetermined
        } else {
            healthKitStatus = .unavailable
        }
        
        // Check Notifications
        Task {
            let settings = await notificationManager.getNotificationSettings()
            await MainActor.run {
                switch settings.authorizationStatus {
                case .authorized:
                    notificationStatus = .authorized
                case .denied:
                    notificationStatus = .denied
                default:
                    notificationStatus = .notDetermined
                }
            }
        }
    }
}

// MARK: - Permission Status

enum PermissionStatus {
    case notDetermined
    case authorized
    case denied
    case unavailable
}

// MARK: - Permission Card

struct PermissionCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let status: PermissionStatus
    let onEnable: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(iconColor)
            }
            
            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.6))
            }
            
            Spacer()
            
            // Status/Action
            statusView
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private var statusView: some View {
        switch status {
        case .notDetermined:
            Button("Enable") {
                onEnable()
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.ironPathPrimary)
            .cornerRadius(20)
            
        case .authorized:
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                Text("Enabled")
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.green)
            
        case .denied:
            Text("Denied")
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.4))
            
        case .unavailable:
            Text("Unavailable")
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.4))
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        PermissionsView(onComplete: {})
    }
}
