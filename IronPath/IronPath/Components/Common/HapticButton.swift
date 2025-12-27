//
//  HapticButton.swift
//  IronPath
//
//  Created by Gabriel Hollenbeck on 12/27/25.
//

import SwiftUI

struct HapticButton<Label: View>: View {
    let action: () -> Void
    let label: Label
    let hapticStyle: HapticStyle
    
    enum HapticStyle {
        case light
        case medium
        case heavy
        case success
    }
    
    init(
        hapticStyle: HapticStyle = .medium,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.hapticStyle = hapticStyle
        self.action = action
        self.label = label()
    }
    
    var body: some View {
        Button(action: {
            triggerHaptic()
            action()
        }) {
            label
        }
    }
    
    private func triggerHaptic() {
        switch hapticStyle {
        case .light:
            HapticManager.lightImpact()
        case .medium:
            HapticManager.mediumImpact()
        case .heavy:
            HapticManager.heavyImpact()
        case .success:
            HapticManager.success()
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HapticButton(hapticStyle: .light) {
            print("Light")
        } label: {
            Text("Light Haptic")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        
        HapticButton(hapticStyle: .success) {
            print("Success")
        } label: {
            Text("Success Haptic")
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

