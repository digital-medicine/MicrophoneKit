//
//  AudioStorage.swift
//  thesis_voice_24
//
//  Created by Leonard Pries on 01.07.24.
//

import AVFoundation
import Combine
import Foundation

final class AudioStorage {
    private var cancellable: AnyCancellable?
    var audioFile: AVAudioFile?


    func setupAudioStorage(audioStream: AnyPublisher<AudioData, AudioManagerError>, output: URL) throws {
        cancellable = audioStream
            .sink(receiveCompletion: { _ in
                self.audioFile = nil
            }, receiveValue: { audioData in
                try? self.writePCMBuffer(buffer: audioData.buffer, output: output)
            })
    }

    func writePCMBuffer(buffer: AVAudioPCMBuffer, output: URL) throws {
        do {
            if audioFile == nil {
                let adjustedUrl = adjustedURLForFormat(output: output, formatID: buffer.format.settings[AVFormatIDKey] as? UInt32)
                audioFile = try openAudioFile(buffer: buffer, output: adjustedUrl)
            }
            try audioFile?.write(from: buffer)
        } catch {
            print("Could not write file, error=\(error.localizedDescription)")
        }
    }

    private func adjustedURLForFormat(output: URL, formatID: UInt32?) -> URL {
            guard let formatID = formatID else { return output }
            let extensionMapping: [UInt32: String] = [
                kAudioFormatLinearPCM: "wav", // or "aif" for AIFF
                kAudioFormatAppleLossless: "m4a",
                kAudioFormatMPEG4AAC: "m4a"
            ]
            let fileExtension = extensionMapping[formatID] ?? "caf" // default to .caf if unknown format
            var newOutput = output
            if output.pathExtension != fileExtension {
                newOutput.deletePathExtension()
                newOutput.appendPathExtension(fileExtension)
            }
            return newOutput
        }

    private func openAudioFile(buffer: AVAudioPCMBuffer, output: URL) throws -> AVAudioFile {
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]

        do {
            let audioFile = try AVAudioFile(forWriting: output, settings: settings, commonFormat: .pcmFormatFloat32, interleaved: false)
            self.audioFile = audioFile
            return audioFile
        } catch {
            debugPrint("☠️ error opening file at \(output.absoluteString)")
            throw error
        }
    }
}
