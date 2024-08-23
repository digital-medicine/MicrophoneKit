//
//  AudioLoudnessAnalyzer.swift
//  thesis_voice_24
//
//  Created by Leonard Pries on 01.07.24.
//

import Combine
import Foundation

final class AudioLoudnessAnalyzer {
    private var cancellable: AnyCancellable?

    private let _analyzerValues = PassthroughSubject<AudioLoudnessAnalyzerData, Never>()
    var publisher: AnyPublisher<AudioLoudnessAnalyzerData, Never> {
        _analyzerValues.eraseToAnyPublisher()
    }

    func setupAnalyzer(audioStream: AnyPublisher<AudioData, AudioManagerError>) throws {
        cancellable = audioStream.sink(
            receiveCompletion: { _ in
                self.cleanup()
            }, receiveValue: { audioData in
                let analyzerData = AudioLoudnessAnalyzerData(audioData: audioData)
                self._analyzerValues.send(analyzerData)
            })
    }

    private func cleanup() {
        _analyzerValues.send(.zero)
        cancellable = nil
    }
}
