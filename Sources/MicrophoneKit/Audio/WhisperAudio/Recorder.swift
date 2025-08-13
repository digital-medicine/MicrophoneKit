//
//  Recorder.swift
//  MicrophoneKit
//
//  Created by Azizi, Imad on 19.04.25.
//

import Foundation
import AVFoundation

// An actor that handles starting and stopping audio recording
public actor Recorder {
    
    private var recorder: AVAudioRecorder?
    
    public init() {}

    enum RecorderError: Error {
        case couldNotStartRecording
    }

    // Starts recording to the given output file
    public func startRecordingWhisper(toOutputFile url: URL, delegate: AVAudioRecorderDelegate?) throws {
        // Configure settings: 16 kHz, mono, linear PCM (WAV format)
        let recordSettings: [String : Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

#if !os(macOS)
        // Required for iOS to allow recording
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default)
#endif

        // Prepare and start recording
        let recorder = try AVAudioRecorder(url: url, settings: recordSettings)
        recorder.delegate = delegate
        if recorder.record() == false {
            print("❌ Could not start recording")
            throw RecorderError.couldNotStartRecording
        }

        self.recorder = recorder
    }

    // Stops recording and releases the recorder instance
    public func stopRecordingWhisper() {
        recorder?.stop()
        recorder = nil
    }
    
    
    public func currentLevel() -> Float {
        guard let r = recorder else { return 0 }
        r.updateMeters()
        // avgPower: dBFS ~ [-160, 0] -> linearisieren und clampen auf 0..1
        let dB = r.averagePower(forChannel: 0)
        let linear = pow(10, dB / 20)
        return max(0, min(1, linear))
    }
}
