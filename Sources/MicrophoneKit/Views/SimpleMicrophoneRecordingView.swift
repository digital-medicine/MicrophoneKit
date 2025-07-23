//
//  SimpleMicrophoneRecordingView.swift
//  MicrophoneKit
//
//  Created by Florian Schweizer on 23.07.25.
//

import SwiftUI
import AVFoundation

public struct SimpleMicrophoneRecordingView: View {
    private let title: String
    private let closeAction: () -> Void
    @State private var viewModel: MicrophoneRecordingViewModel
    @State private var audioWaveViewModel: AudioWaveViewModel
    
    public init(
        fileName: String,
        title: String,
        afterSave: @escaping (URL) -> Void,
        closeAction: @escaping () -> Void
    ) {
        self.closeAction = closeAction
        self.title = title
        let audioWave = AudioWaveViewModel()
        self._audioWaveViewModel = State(wrappedValue: audioWave)
        self._viewModel = State(wrappedValue: MicrophoneRecordingViewModel(fileName: fileName, afterSave: afterSave,  onNewData: { data in
            audioWave.addNumber(data)
        }))
    }
    
    public var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Spacer()
            
            AudioWaveView(viewModel: $audioWaveViewModel)
                
            Text(viewModel.timeFormatted)
                .font(.system(size: 48))
                .fontWeight(.medium)
                .fontDesign(.monospaced)
                .padding()
            
            Spacer()
            
            HStack {
                IconButton(
                    iconName: "arrow.clockwise",
                    label: "Retry",
                    color: .black,
                    action: {
                    viewModel.restart()
                })
                
                if (viewModel.audioStreamManager.audioStreamManagerState == .idle) {
                    IconButton(
                        iconName: "record.circle",
                        label: "Start",
                        color: Color(red: 110 / 255, green: 186 / 255, blue: 180 / 255),
                        action: {
                        viewModel.startRecording()
                    })
                } else {
                    IconButton(
                        iconName: "stop.circle",
                        label: "Stop",
                        color: Color(red: 227 / 255, green: 128 / 255, blue: 124 / 255),
                        action: {
                        viewModel.stopRecording()
                    })
                }
            }
            
            Spacer()
            
            instructionAction
        }
    }
    
    @MainActor
    @ViewBuilder
    private var instructionAction: some View {
        Button {
            closeAction()
        } label: {
            Text("Next")
                .font(.system(size: 30))
                .bold()
                .frame(height: 30)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding(.vertical, 25)
        .padding(.horizontal)
    }
}
