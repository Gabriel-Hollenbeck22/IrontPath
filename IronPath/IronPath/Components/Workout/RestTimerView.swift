//
//  RestTimerView.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI

struct RestTimerView: View {
    @State private var timeRemaining: Int
    @State private var isActive = false
    @State private var timer: Timer?
    
    let initialSeconds: Int
    let onComplete: () -> Void
    
    init(seconds: Int = AppConfiguration.defaultRestTimerSeconds, onComplete: @escaping () -> Void = {}) {
        self.initialSeconds = seconds
        self._timeRemaining = State(initialValue: seconds)
        self.onComplete = onComplete
    }
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                
                Circle()
                    .trim(from: 0, to: Double(timeRemaining) / Double(initialSeconds))
                    .stroke(Color.ironPathPrimary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timeRemaining)
                
                Text(FormatHelpers.restTimer(timeRemaining))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
            .frame(width: 120, height: 120)
            
            HStack(spacing: Spacing.md) {
                Button(isActive ? "Pause" : "Start") {
                    isActive.toggle()
                    if isActive {
                        startTimer()
                        HapticManager.lightImpact()
                    } else {
                        stopTimer()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Reset") {
                    timeRemaining = initialSeconds
                    isActive = false
                    stopTimer()
                    HapticManager.lightImpact()
                }
                .buttonStyle(.bordered)
            }
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
                HapticManager.success()
                onComplete()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    RestTimerView()
        .padding()
}

