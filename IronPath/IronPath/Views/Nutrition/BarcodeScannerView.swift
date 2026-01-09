//
//  BarcodeScannerView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI
import SwiftData
import VisionKit

struct BarcodeScannerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let onFoodScanned: ((FoodItem) -> Void)?
    
    init(onFoodScanned: ((FoodItem) -> Void)? = nil) {
        self.onFoodScanned = onFoodScanned
    }
    
    @State private var nutritionService: NutritionService?
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .accurate,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        
        scanner.delegate = context.coordinator
        
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        // Start scanning when view appears
        if !uiViewController.isScanning {
            try? uiViewController.startScanning()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let parent: BarcodeScannerView
        
        init(_ parent: BarcodeScannerView) {
            self.parent = parent
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .barcode(let barcode):
                if let payload = barcode.payloadStringValue {
                    Task {
                        await parent.searchByBarcode(payload)
                    }
                }
            default:
                break
            }
        }
    }
    
    private func searchByBarcode(_ barcode: String) async {
        let service = NutritionService(modelContext: modelContext)
        
        do {
            if let foodItem = try await service.searchByBarcode(barcode) {
                await MainActor.run {
                    HapticManager.success()
                    onFoodScanned?(foodItem)
                    dismiss()
                }
            } else {
                await MainActor.run {
                    HapticManager.error()
                }
            }
        } catch {
            print("Barcode search error: \(error)")
            await MainActor.run {
                HapticManager.error()
            }
        }
    }
}

#Preview {
    BarcodeScannerView { foodItem in
        print("Scanned: \(foodItem.name)")
    }
}

