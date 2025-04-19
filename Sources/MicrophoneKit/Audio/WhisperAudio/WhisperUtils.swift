//
//  WhisperUtils.swift
//  MicrophoneKit
//
//  Created by Azizi, Imad on 18.04.25.
//

import Foundation

/// Decodes a WAV file into an array of float samples (needed to use whisper)
/// Supports mono 16-bit PCM format with 44-byte header
public func decodeWaveFile(_ url: URL) throws -> [Float] {
    let data = try Data(contentsOf: url)
    
    // WAV Header is 44 bytes, data starts from there
    let floats = stride(from: 44, to: data.count, by: 2).map {
        data[$0..<$0 + 2].withUnsafeBytes {
            let sample = Int16(littleEndian: $0.load(as: Int16.self))
            return max(-1.0, min(Float(sample) / 32767.0, 1.0))
        }
    }
    
    return floats
}


/// Helper to write float samples as WAV file with standard header
public func writeWaveFile(samples: [Float], to url: URL) throws {
    var data = Data()
    let sampleCount = samples.count
    let sampleRate: UInt32 = 16000
    let bitsPerSample: UInt16 = 16
    let numChannels: UInt16 = 1
    let byteRate = sampleRate * UInt32(bitsPerSample / 8)

    // Header chunk
    data.append("RIFF".data(using: .ascii)!)
    data.append(UInt32(36 + sampleCount * 2).littleEndianData)
    data.append("WAVE".data(using: .ascii)!)
    data.append("fmt ".data(using: .ascii)!)
    data.append(UInt32(16).littleEndianData)
    data.append(UInt16(1).littleEndianData)
    data.append(numChannels.littleEndianData)
    data.append(sampleRate.littleEndianData)
    data.append(byteRate.littleEndianData)
    data.append(UInt16(numChannels * bitsPerSample / 8).littleEndianData)
    data.append(bitsPerSample.littleEndianData)
    data.append("data".data(using: .ascii)!)
    data.append(UInt32(sampleCount * 2).littleEndianData)

    // PCM Data
    for float in samples {
        let clamped = max(-1.0, min(1.0, float))
        let int16 = Int16(clamped * Float(Int16.max))
        data.append(int16.toBytes())
    }

    try data.write(to: url)
}

fileprivate extension FixedWidthInteger {
    var littleEndianData: Data {
        var value = self.littleEndian
        return withUnsafeBytes(of: &value) { Data($0) }
    }
}

extension Int16 {
    func toBytes() -> Data {
        var value = self.littleEndian
        return withUnsafeBytes(of: &value) { Data($0) }
    }
}
