//
//  AudioContinuousAnalyzer.swift
//  thesis_voice_24
//
//  Created by Leonard Pries on 13.06.24.
//

import AVFoundation
import Combine
import Foundation

final class AudioSequentAnalyzer<T: SequentAnalyzerData> {
    private var cancellable: AnyCancellable?

    private let _analyzerValues = PassthroughSubject<T, Never>()
    var publisher: AnyPublisher<T, Never> {
        _analyzerValues.eraseToAnyPublisher()
    }

    func setupAnalyzer(audioStream: AnyPublisher<AudioData, AudioManagerError>) throws {
        cancellable = audioStream.sink(
            receiveCompletion: { _ in
                self.cleanup()
            }, receiveValue: { audioData in
                let analyzerData = T(audioData: audioData)
                self._analyzerValues.send(analyzerData)
            })
    }

    private func cleanup() {
        _analyzerValues.send(.zero)
        cancellable = nil
    }
}

protocol SequentAnalyzerData {
    static var zero: Self { get }
    init(audioData: AudioData)
}
