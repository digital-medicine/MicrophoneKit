//
//  AudioStreamManagerConfig.swift
//  thesis_voice_24
//
//  Created by Leonard Pries on 13.06.24.
//

import AVFoundation
import Foundation

struct AudioStreamManagerConfig {
    let busIndex: AVAudioNodeBus
    let bufSize: AVAudioFrameCount

    init(busIndex: AVAudioNodeBus = 0, bufSize: AVAudioFrameCount = AVAudioFrameCount(4096)) {
        self.busIndex = busIndex
        self.bufSize = bufSize
    }
}
