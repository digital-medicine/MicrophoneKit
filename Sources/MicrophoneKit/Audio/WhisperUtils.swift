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
