//
//  AudioStreamManager.swift
//  thesis_voice_24
//
//  Created by Leonard Pries on 13.06.24.
//

import AVFoundation
import Combine
import Foundation

/// `AudioStreamManagerState` can be used to provide information about
/// what's happening in the UI.
///
/// - idle: The AudioStreamManager does nothing. Just show a start / record button.
/// - streaming: TheAudioStreamManager captures audio.
/// - error: Something went wrong
public enum AudioStreamManagerState: Equatable {
    case idle
    case streaming(sampleTime: Int64)
    case error(message: String)
    
    public static func == (lhs: AudioStreamManagerState, rhs: AudioStreamManagerState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case let (.streaming(sampleTimeL), .streaming(sampleTimeR)):
            return sampleTimeL == sampleTimeR
        case let (.error(messageL), .error(messageR)):
            return messageL == messageR
        default:
            return false
        }
    }
}

final public class AudioStreamManager: NSObject, ObservableObject {
    /// Our audio stream configuration.
    var config: AudioStreamManagerConfig?
    
    /// Our instance of the `AVAudioEngine` for streaming.
    private var audioEngine = AVAudioEngine()
    
    /// Get information about the audio format the `AVAudioEngine` provides us.
    var audioFormat: AVAudioFormat? {
        guard let config else { return nil }
        return audioEngine.inputNode.inputFormat(forBus: config.busIndex)
    }
    
    /// Publisher for the audio stream manager state. Can be used to show the streaming state or
    /// change buttons in our user infterface.
    @Published var audioStreamManagerState: AudioStreamManagerState = .idle
    
    /// Publisher for audio streams. The stream will be closed when the audio streaming
    /// is stopped and needs to be subscribed again.
    private var _audioStream: PassthroughSubject<AudioData, AudioManagerError>?
    var audioStream: AnyPublisher<AudioData, AudioManagerError> {
        guard let audioStream = _audioStream else {
            let audioStream = PassthroughSubject<AudioData, AudioManagerError>()
            _audioStream = audioStream
            return audioStream.eraseToAnyPublisher()
        }
        return audioStream.eraseToAnyPublisher()
    }
    
    /// Request authorization for using the microphone. This must be called once before any audiodata can
    /// be captured. The permission for audio recording remains for this App. Async function.
    func requestAuthorization() async -> Bool {
        await AudioAuthorization.awaitAuthorization
    }
    
    /// Setup an audio caputre session using the specified `AudioStreamManagerConfig` with information
    /// about the audio bus and data size. This function must be called before start capturing audio data.
    ///
    /// - parameter config: AudioStreamManagerConfig to be used.
    /// - returns  the `AVAudioFormat` for the capture session. Can also be requested later via `self.audioFormat`
    @discardableResult
    func setupCaptureSession(config: AudioStreamManagerConfig = .init(), using inputDevice: AVAudioSessionPortDescription? = nil) throws -> AVAudioFormat {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            
            // Set the preferred input, if one is provided
            if let inputDevice = inputDevice {
                try audioSession.setPreferredInput(inputDevice)
            }
            
            guard AudioAuthorization.isAuthorized else {
                throw AudioManagerError.notAuthorized
            }
            
            self.config = config
            
            let audioFormat = audioEngine.inputNode.inputFormat(forBus: config.busIndex)
            audioEngine.inputNode.installTap(onBus: config.busIndex, bufferSize: config.bufSize,
                                             format: audioFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                DispatchQueue.main.async {
                    // Must change the published value on main thread
                    self.audioStreamManagerState = .streaming(sampleTime: when.sampleTime)
                }
                self._audioStream?.send(AudioData(buffer: buffer, when: when))
            }
            return audioFormat
        } catch {
            throw AudioManagerError.other(error)
        }
    }
    
    /// Start the audio engine and capture audio data.
    func start() throws {
        try audioEngine.start()
    }
    
    /// Stop capturing audio data. After stopping the session, all audio data subscribers
    /// receive a `completion(.finish)`.
    func stop() {
        guard let config = config else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: config.busIndex)
        _audioStream?.send(completion: .finished)
        _audioStream = nil
        audioStreamManagerState = .idle
    }
}

// MARK: - Extension for AVAudioPCMBuffer

extension AVAudioPCMBuffer {
    /// Convert the PCM buffer to a Data object and copy the sample data.
    ///
    /// IMPORTANT: We need the `floatChannelData` because
    /// It contains the wave data as negative and positive samples that can easyly be displayed.
    ///
    var data: Data {
        let channelCount = 1
        let channels = UnsafeBufferPointer(start: floatChannelData, count: channelCount)
        let ch0data = NSData(bytes: channels[0],
                             length: Int(frameCapacity * format.streamDescription.pointee.mBytesPerFrame))
        return ch0data as Data
    }
}
