//
//  File.swift
//  
//
//  Created by Leonard Pries on 23.08.24.
//

import Foundation
import AVFoundation

@Observable class AudioInputManager {
    var inputDevice: AVAudioSessionPortDescription?
    
    init() {
        self.inputDevice = getAllAvailableInputs().first
    }
    
    /// Retrieves all available audio input devices.
    func getAllAvailableInputs() -> [AVAudioSessionPortDescription] {
        do {
            // Ensure the audio session is active to query inputs
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(true)
            // Return all available inputs
            return audioSession.availableInputs ?? []
        } catch {
            print("Failed to get available inputs: \(error)")
            return []
        }
    }
    
    func selectInput(inputDevice: AVAudioSessionPortDescription) {
        self.inputDevice = inputDevice
    }
}
    
