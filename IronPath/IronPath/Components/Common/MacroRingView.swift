//
//  MacroRingView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI

struct MacroRingView: View {
    let current: Double
    let target: Double
    let color: Color
    let label: String
    
    var progress: Double {
        min(current / target, 1.0)
    }
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                
                VStack(spacing: 2) {
                    Text("\(Int(current))")
                        .font(.headline)
                    Text("/ \(Int(target))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 80, height: 80)
            
            Text(label)
                .font(.caption)
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        MacroRingView(
            current: 120,
            target: 150,
            color: .macroProtein,
            label: "Protein"
        )
        MacroRingView(
            current: 180,
            target: 200,
            color: .macroCarbs,
            label: "Carbs"
        )
        MacroRingView(
            current: 50,
            target: 65,
            color: .macroFat,
            label: "Fat"
        )
    }
    .padding()
}

