//
//  AudioSubsequentAnalyser.swift
//  thesis_voice_24
//
//  Created by Leonard Pries on 01.07.24.
//

import AVFoundation
import Combine
import Foundation

final class AudioSubsequentAnalyzer<T: SubsequentAnalyzerData> {
    private var cancellable: AnyCancellable?
    private var audioDataBuffer: [AudioData] = []

    private let _analyzedResult = PassthroughSubject<T, Never>()
    var resultPublisher: AnyPublisher<T, Never> {
        _analyzedResult.eraseToAnyPublisher()
    }

    func setupAnalyzer(audioStream: AnyPublisher<AudioData, AudioManagerError>) {
        cancellable = audioStream.sink(
            receiveCompletion: { [weak self] _ in
                self?.performAnalysis()
            }, receiveValue: { [weak self] audioData in
                self?.audioDataBuffer.append(audioData)
            })
    }

    private func performAnalysis() {
        let analyzedResult = T(audioDataArray: audioDataBuffer)
        _analyzedResult.send(analyzedResult)
        cleanup()
    }

    private func cleanup() {
        audioDataBuffer.removeAll()
        cancellable = nil
    }
}

protocol SubsequentAnalyzerData {
    static var zero: Self { get }
    init(audioDataArray: [AudioData])
}
