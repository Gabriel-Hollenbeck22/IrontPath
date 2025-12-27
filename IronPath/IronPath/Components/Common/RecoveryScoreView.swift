//
//  RecoveryScoreView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI

struct RecoveryScoreView: View {
    let score: Double
    let size: CGFloat
    
    var scoreColor: Color {
        if score >= 80 {
            return .recoveryHigh
        } else if score >= 60 {
            return .recoveryMedium
        } else {
            return .recoveryLow
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: size * 0.1)
            
            Circle()
                .trim(from: 0, to: score / 100.0)
                .stroke(scoreColor, style: StrokeStyle(lineWidth: size * 0.1, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: score)
            
            VStack(spacing: 4) {
                Text("\(Int(score))")
                    .font(.system(size: size * 0.3, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text("/ 100")
                    .font(.system(size: size * 0.12, weight: .regular))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 40) {
        RecoveryScoreView(score: 85, size: 150)
        RecoveryScoreView(score: 65, size: 120)
        RecoveryScoreView(score: 45, size: 100)
    }
    .padding()
}

