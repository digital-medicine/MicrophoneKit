//
//  File.swift
//  
//
//  Created by Leonard Pries on 22.08.24.
//

import Foundation

@Observable class CountdownTimer {
    var timeRemaining: Double = 10.0
    var timer: Timer?
    var completion: (() -> Void)?

    func startCountdown() {
        resetTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func stopCountdown() {
        timer?.invalidate()
        timer = nil
    }

    func resetTimer() {
        timeRemaining = 10.0
    }

    private func tick() {
        if timeRemaining > 0 {
            timeRemaining -= 0.1
        } else {
            timeRemaining = 0
            stopCountdown()
            completion?()
        }
    }
}
