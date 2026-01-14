//
//  HealthKitSettingsView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI

struct HealthKitSettingsView: View {
    @State private var healthKitManager = HealthKitManager()
    @State private var isAuthorized = false
    @State private var isRequesting = false
    @State private var isSyncing = false
    @State private var autoSyncEnabled = true
    
    @AppStorage("healthkit_auto_sync") private var autoSyncSetting = true
    @AppStorage("healthkit_last_sync") private var lastSyncTimestamp: Double = 0
    
    private var lastSyncDate: Date? {
        lastSyncTimestamp > 0 ? Date(timeIntervalSince1970: lastSyncTimestamp) : nil
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
                        
                        Image(systemName: isAuthorized ? "checkmark.circle.fill" : "heart.fill")
                            .font(.title2)
                            .foregroundStyle(isAuthorized ? Color.ironPathSuccess : .orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isAuthorized ? "Connected" : "Not Connected")
                            .font(.headline)
                        
                        Text(isAuthorized ? "HealthKit data is syncing" : "Tap to connect Apple Health")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if !isAuthorized && !isRequesting {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if isRequesting {
                        ProgressView()
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if !isAuthorized && !isRequesting {
                        requestAuthorization()
                    }
                }
            } header: {
                Text("Connection Status")
            } footer: {
                Text("IronPath reads your sleep, weight, activity, and step data to provide personalized recovery scores and accurate calorie tracking.")
            }
            
            if isAuthorized {
                // Auto-Sync Toggle
                Section {
                    Toggle(isOn: $autoSyncEnabled) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Auto-Sync")
                                Text("Automatically sync when app opens")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundStyle(Color.ironPathPrimary)
                        }
                    }
                    .onChange(of: autoSyncEnabled) { _, newValue in
                        autoSyncSetting = newValue
                    }
                } header: {
                    Text("Sync Settings")
                }
                
                // Data Types Section
                Section {
                    DataTypeRow(
                        icon: "scalemass.fill",
                        title: "Body Weight",
                        value: healthKitManager.latestBodyWeight.map { "\(Int($0)) lbs" },
                        color: .teal
                    )
                    
                    DataTypeRow(
                        icon: "bed.double.fill",
                        title: "Sleep",
                        value: healthKitManager.todaySleepHours.map { String(format: "%.1f hrs", $0) },
                        color: .indigo
                    )
                    
                    DataTypeRow(
                        icon: "flame.fill",
                        title: "Active Calories",
                        value: healthKitManager.todayActiveCalories.map { "\(Int($0)) cal" },
                        color: .orange
                    )
                    
                    DataTypeRow(
                        icon: "figure.walk",
                        title: "Steps",
                        value: healthKitManager.todaySteps.map { "\($0)" },
                        color: .green
                    )
                } header: {
                    Text("Today's Data")
                } footer: {
                    if let lastSync = lastSyncDate {
                        Text("Last synced: \(lastSync.formatted(date: .abbreviated, time: .shortened))")
                    }
                }
                
                // Manual Sync Section
                Section {
                    Button {
                        syncData()
                    } label: {
                        HStack {
                            Label("Sync Now", systemImage: "arrow.clockwise")
                            
                            Spacer()
                            
                            if isSyncing {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isSyncing)
                }
            }
            
            // About Section
            Section {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Label("Privacy First", systemImage: "lock.shield.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.ironPathPrimary)
                    
                    Text("Your health data stays on your device and is never uploaded to external servers. IronPath only reads data you've authorized.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, Spacing.xs)
            }
        }
        .navigationTitle("Apple Health")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isAuthorized = healthKitManager.isAuthorized
            autoSyncEnabled = autoSyncSetting
            
            if isAuthorized && autoSyncSetting {
                syncData()
            }
        }
    }
    
    private func requestAuthorization() {
        isRequesting = true
        HapticManager.mediumImpact()
        
        Task {
            do {
                try await healthKitManager.requestAuthorization()
                await MainActor.run {
                    isAuthorized = true
                    isRequesting = false
                    HapticManager.success()
                    // Sync after authorization
                    syncData()
                }
            } catch {
                print("HealthKit authorization error: \(error)")
                await MainActor.run {
                    isRequesting = false
                    HapticManager.error()
                }
            }
        }
    }
    
    private func syncData() {
        isSyncing = true
        
        Task {
            do {
                try await healthKitManager.syncTodaysData()
                await MainActor.run {
                    lastSyncTimestamp = Date().timeIntervalSince1970
                    isSyncing = false
                    HapticManager.lightImpact()
                }
            } catch {
                print("Sync error: \(error)")
                await MainActor.run {
                    isSyncing = false
                }
            }
        }
    }
}

// MARK: - Data Type Row

private struct DataTypeRow: View {
    let icon: String
    let title: String
    let value: String?
    let color: Color
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
            }
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            } else {
                Text("No data")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HealthKitSettingsView()
    }
}
