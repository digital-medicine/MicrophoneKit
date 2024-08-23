//
//  AudioFrequencyAnalyzer.swift
//  thesis_voice_24
//
//  Created by Leonard Pries on 01.07.24.
//

import Accelerate
import AVFoundation
import Foundation

/// `AudioFrequencyAnalyzerData` structure.
///
/// We use this to calculate values that are related to the frequencies of an `AudioData` buffer.
struct AudioFrequencyAnalyzerData: SequentAnalyzerData {
    let time: Int64
    let frequency: Float
    let spectralCentroid: Float
    let spectralBandwidth: Float

    static var zero = AudioFrequencyAnalyzerData(time: 0, frequency: 0, spectralCentroid: 0, spectralBandwidth: 0)

    var debugDescription: String {
        "\(time) frequency=\(frequency), spectralCentroid=\(spectralCentroid), spectralBandwidth=\(spectralBandwidth)"
    }

    init(time: Int64, frequency: Float, spectralCentroid: Float, spectralBandwidth: Float) {
        self.time = time
        self.frequency = frequency
        self.spectralCentroid = spectralCentroid
        self.spectralBandwidth = spectralBandwidth
    }

    init(audioData: AudioData) {
        self.time = audioData.when.sampleTime

        guard let samples = audioData.samples else {
            self.frequency = 0
            self.spectralCentroid = 0
            self.spectralBandwidth = 0
            return
        }

        let log2n = vDSP_Length(log2(Float(samples.count)))
        guard let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else {
            fatalError("Unable to create FFT setup.")
        }

        var realp = [Float](repeating: 0, count: samples.count / 2)
        var imagp = [Float](repeating: 0, count: samples.count / 2)

        // Perform FFT
        var calculatedFrequency: Float = 0
        var spectralCentroid: Float = 0
        var spectralBandwidth: Float = 0

        realp.withUnsafeMutableBufferPointer { realpPtr in
            imagp.withUnsafeMutableBufferPointer { imagpPtr in
                var splitComplex = DSPSplitComplex(realp: realpPtr.baseAddress!, imagp: imagpPtr.baseAddress!)

                samples.withUnsafeBufferPointer { samplePtr in
                    samplePtr.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: samples.count / 2) { complexPtr in
                        vDSP_ctoz(complexPtr, 2, &splitComplex, 1, vDSP_Length(samples.count / 2))
                    }
                }

                vDSP_fft_zrip(fftSetup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))

                var magnitudes = [Float](repeating: 0.0, count: samples.count / 2)
                vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(samples.count / 2))

                // Normalize magnitudes by creating a local copy first
                let normalizationFactor: Float = 1.0 / sqrtf(Float(samples.count))
                var normalizedMagnitudes = magnitudes
                vDSP_vsmul(&magnitudes, 1, [normalizationFactor], &normalizedMagnitudes, 1, vDSP_Length(samples.count / 2))

                // Find the frequency with the highest magnitude
                guard let maxMagnitude = normalizedMagnitudes.max(),
                      let maxIndex = normalizedMagnitudes.firstIndex(of: maxMagnitude)
                else {
                    return
                }

                calculatedFrequency = Float(maxIndex) * Float(audioData.buffer.format.sampleRate) / Float(samples.count)

                // Calculate the spectral centroid
                var weightedFrequencies = [Float](repeating: 0.0, count: normalizedMagnitudes.count)
                vDSP_vmul(normalizedMagnitudes, 1, (0..<normalizedMagnitudes.count).map { Float($0) }, 1, &weightedFrequencies, 1, vDSP_Length(normalizedMagnitudes.count))
                let sumOfWeights = normalizedMagnitudes.reduce(0, +)
                let sumOfWeightedFrequencies = weightedFrequencies.reduce(0, +)
                spectralCentroid = sumOfWeightedFrequencies / sumOfWeights * Float(audioData.buffer.format.sampleRate) / Float(samples.count)

                // Calculate the spectral bandwidth
                let differences = weightedFrequencies.map { pow($0 - spectralCentroid, 2) }
                let sumOfDifferences = differences.reduce(0, +)
                spectralBandwidth = sqrt(sumOfDifferences / sumOfWeights)
            }
        }

        vDSP_destroy_fftsetup(fftSetup)

        self.frequency = calculatedFrequency
        self.spectralCentroid = spectralCentroid
        self.spectralBandwidth = spectralBandwidth
    }
}
