//
//  AudioDataProcessor.swift
//  thesis_voice_24
//
//  Created by Leonard Pries on 13.06.24.
//

import AVFoundation
import Foundation

/// This structure is used to transport received audio data with time information
/// to audio processors or subscribers via Combine.
struct AudioData {
    let buffer: AVAudioPCMBuffer
    let when: AVAudioTime

    var samples: [Float]? {
        let arraySize = Int(buffer.frameLength)
        guard let channelData = buffer.floatChannelData else {
            return nil
        }
        let samples: [Float] = Array(UnsafeBufferPointer(start: channelData[0], count: arraySize))
        return samples
    }

    var max: Float {
        guard let samples = samples else { return 0 }
        let maxVolume: Float = samples.reduce(0.0) { partialResult, sample in
            sample > partialResult ? sample : partialResult
        }
        return maxVolume
    }
}

protocol AudioDataProcessor: AnyObject {
    func startProcessing()
    func endProcessing()
    func processNext(_ audioBuffer: AudioData) throws
}

extension AudioDataProcessor {
    func startProcessing() {}
    func endProcessing() {}
    func processNext(_ audioBuffer: AudioData) throws {}
}
