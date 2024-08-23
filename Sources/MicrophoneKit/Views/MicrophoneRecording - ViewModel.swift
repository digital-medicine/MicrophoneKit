//
//  File.swift
//
//
//  Created by Leonard Pries on 22.08.24.
//

import AVFoundation
import Combine
import Foundation
import SoundAnalysis

@Observable class MicrophoneRecordingViewModel {
    let audioStreamManager = AudioStreamManager()
    let audioStorage = AudioStorage()
    var cancellables = Set<AnyCancellable>()
    var audioInputManager = AudioInputManager()
    private let audioLoudnessAnalyzer = AudioSequentAnalyzer<AudioLoudnessAnalyzerData>()
    
    // Timer
    private var timer: Timer?
    private var tenthsOfSecondElapsed = 0
    private var isTimerRunning = false
    
    // Config
    private let fileName: String
    private let afterSave: (URL) -> Void
    private var onNewData: (Double) -> Void
    
    init(fileName: String, afterSave: @escaping (URL) -> Void, onNewData: @escaping (Double) -> Void) {
        self.fileName = fileName
        self.afterSave = afterSave
        self.onNewData = onNewData
        Task {
            await audioStreamManager.requestAuthorization()
        }
    }
    
    func startRecording() {
        print("🎙️ start analyze")
        do {
            try audioStreamManager.setupCaptureSession(using: audioInputManager.inputDevice)
            try audioLoudnessAnalyzer.setupAnalyzer(audioStream: audioStreamManager.audioStream)
            
            audioLoudnessAnalyzer.publisher
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                }) { data in
                    
                    self.onNewData(Double(data.rmsAmplitude))
                }
                .store(in: &cancellables)
            
            let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentPath.appendingPathComponent("\(fileName).wav")
            try audioStorage.setupAudioStorage(audioStream: audioStreamManager.audioStream, output: audioFilename)
            
            try audioStreamManager.start()
            startTimer()
        } catch {
            print("☠️ analyzer not started, error=\(error)")
        }
    }
    
    func stopRecording() {
        print("🎙️ stop analyze")
        if let url = audioStorage.audioFile?.url {
            print("URL: \(url)")
            audioStreamManager.stop()
            afterSave(url)
        }
        stopTimer()
    }
    
    func restart() {
        print("🎙️ stop analyze")
        if let url = audioStorage.audioFile?.url {
            print("URL: \(url)")
            audioStreamManager.stop()
            afterSave(url)
        }
        startRecording()
    }
    
    var timeFormatted: String {
        let seconds = tenthsOfSecondElapsed / 10
        let tenths = tenthsOfSecondElapsed % 10
        return String(format: "%02d:%01d", seconds, tenths)
    }
    
    private func startTimer() {
        if !isTimerRunning {
            isTimerRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.tenthsOfSecondElapsed += 1
            }
        }
    }
    
    private func stopTimer() {
        isTimerRunning = false
        timer?.invalidate()
        tenthsOfSecondElapsed = 0
        timer = nil
    }
}
