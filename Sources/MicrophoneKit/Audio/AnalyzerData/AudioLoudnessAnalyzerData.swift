//
//  AudioLoudnessAnalyzerData.swift
//  thesis_voice_24
//
//  Created by Leonard Pries on 01.07.24.
//

import AVFoundation
import Foundation

/// `AudioLoudnessAnalyzerData` structure.
///
/// We use this to calculate values that are related to the loudness of an `AudioData` buffer.
/// Values are in decibels, peak amplitude and Root Mean Square (RMS) amplitude.
struct AudioLoudnessAnalyzerData: SequentAnalyzerData {
    let time: Int64
    let dB: Float
    let peakAmplitude: Float
    let rmsAmplitude: Float

    static var zero = AudioLoudnessAnalyzerData(time: 0, dB: 0, peakAmplitude: 0, rmsAmplitude: 0)

    var debugDescription: String {
        "\(time) dB=\(dB) peak=\(peakAmplitude) rms=\(rmsAmplitude)"
    }

    init(time: Int64, dB: Float, peakAmplitude: Float, rmsAmplitude: Float) {
        self.time = time
        self.dB = dB
        self.peakAmplitude = peakAmplitude
        self.rmsAmplitude = rmsAmplitude
    }

    init(audioData: AudioData) {
        self.time = audioData.when.sampleTime

        guard let samples = audioData.samples else {
            self.dB = 0
            self.peakAmplitude = 0
            self.rmsAmplitude = 0
            return
        }

        // Calculate Peak Amplitude
        let peakAmplitude = samples.reduce(0) { max($0, abs($1)) }
        self.peakAmplitude = peakAmplitude

        // Calculate RMS
        let rms = sqrt(samples.map { $0 * $0 }.reduce(0, +) / Float(samples.count))
        self.rmsAmplitude = rms

        // Calculate Decibels from RMS
        self.dB = 20 * log10(rms / 1.0)
    }
}
