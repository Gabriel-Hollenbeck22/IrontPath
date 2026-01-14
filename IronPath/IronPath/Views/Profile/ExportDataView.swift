//
//  ExportDataView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 1/14/26.
//

import SwiftUI
import SwiftData

struct ExportDataView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedExportType: ExportType = .all
    @State private var isExporting = false
    @State private var exportedURL: URL?
    @State private var showingShareSheet = false
    @State private var errorMessage: String?
    @State private var showingError = false
    
    var body: some View {
        List {
            Section {
                ForEach(ExportType.allCases) { type in
                    ExportOptionRow(
                        type: type,
                        isSelected: selectedExportType == type,
                        onSelect: {
                            HapticManager.selection()
                            selectedExportType = type
                        }
                    )
                }
            } header: {
                Text("Select Data to Export")
            } footer: {
                Text("Data will be exported as CSV files that can be opened in Excel, Google Sheets, or any spreadsheet application.")
            }
            
            Section {
                Button {
                    exportData()
                } label: {
                    HStack {
                        if isExporting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        
                        Text(isExporting ? "Exporting..." : "Export \(selectedExportType.rawValue)")
                    }
                    .frame(maxWidth: .infinity)
                }
                .disabled(isExporting)
            }
            
            Section {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Label("Privacy Note", systemImage: "lock.shield.fill")
                        .font(.subheadline.weight(.semibold))
                    
                    Text("Your data is exported locally and never sent to our servers. You control where the exported files are shared or saved.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, Spacing.xs)
            }
        }
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportedURL {
                ExportShareSheet(url: url)
            }
        }
        .alert("Export Error", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
    }
    
    private func exportData() {
        isExporting = true
        HapticManager.lightImpact()
        
        Task {
            do {
                let exportService = DataExportService(modelContext: modelContext)
                let url: URL
                
                switch selectedExportType {
                case .workouts:
                    url = try exportService.exportWorkouts()
                case .workoutSets:
                    url = try exportService.exportWorkoutSets()
                case .nutrition:
                    url = try exportService.exportNutritionLog()
                case .dailySummaries:
                    url = try exportService.exportDailySummaries()
                case .weight:
                    url = try exportService.exportWeightHistory()
                case .all:
                    url = try exportService.exportAllData()
                }
                
                await MainActor.run {
                    exportedURL = url
                    isExporting = false
                    showingShareSheet = true
                    HapticManager.success()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isExporting = false
                    showingError = true
                    HapticManager.error()
                }
            }
        }
    }
}

// MARK: - Export Option Row

struct ExportOptionRow: View {
    let type: ExportType
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: type.icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.ironPathPrimary : .secondary)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(type.rawValue)
                        .font(.body)
                        .foregroundStyle(.primary)
                    
                    Text(type.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.ironPathPrimary)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Export Share Sheet

struct ExportShareSheet: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        ExportDataView()
    }
    .modelContainer(for: [Workout.self, LoggedFood.self], inMemory: true)
}
