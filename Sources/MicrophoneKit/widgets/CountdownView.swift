//
//  SwiftUIView.swift
//  
//
//  Created by Leonard Pries on 22.08.24.
//

import SwiftUI

struct CountdownView: View {
    @Binding var countdownTimer: CountdownTimer

    var body: some View {
        VStack {
            Text(String(format: "%.1f", max(countdownTimer.timeRemaining, 0)))
                .font(.system(size: 72))
                .padding()
        }
        .onAppear {
            countdownTimer.completion = {
                print("Countdown finished!")
            }
        }
    }
}

#Preview {
    let countdownTimer = CountdownTimer()
    return CountdownView(countdownTimer: .constant(countdownTimer))
}
