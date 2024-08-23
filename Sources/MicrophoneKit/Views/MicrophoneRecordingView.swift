//
//  MicrophoneRecordingView.swift
//
//
//  Created by Leonard Pries on 22.08.24.
//

import SwiftUI
import AVFoundation

public struct MicrophoneRecordingView: View {
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
                .font(.headline)
            audioInputPicker
            Spacer()
            AudioWaveView(viewModel: $audioWaveViewModel)
            Text(viewModel.timeFormatted)
                .font(.system(size: 48, weight: .medium, design: .monospaced))
                .padding()
            
            Spacer()
            HStack {
                IconButton(iconName: "arrow.clockwise", label: "Retry", color: .black, action: {
                    viewModel.restart()
                })
                if (viewModel.audioStreamManager.audioStreamManagerState == .idle) {
                    IconButton(iconName: "record.circle", label: "Start", color: Color(red: 110 / 255, green: 186 / 255, blue: 180 / 255), action: {
                        viewModel.startRecording()
                    })
                } else {
                    IconButton(iconName: "stop.circle", label: "Stop", color: Color(red: 227 / 255, green: 128 / 255, blue: 124 / 255), action: {
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
    
    @ViewBuilder
    private var audioInputPicker: some View {
        VStack {
            Text("Select Audio Input")
                .font(.headline)
            Picker("Select Audio Input", selection: $viewModel.audioInputManager.inputDevice) {
                ForEach(viewModel.audioInputManager.getAllAvailableInputs() ?? [], id: \.uid) { input in
                    Text(input.portName).tag(input as AVAudioSessionPortDescription?)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .disabled(viewModel.audioStreamManager.audioStreamManagerState != .idle)
        }
        .padding()
    }
}

struct IconButton: View {
    let iconName: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        VStack {
            Button(action: action) {
                
                Image(systemName: iconName)
                    .resizable()
                    .foregroundColor(.white)
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
                
            }
            .frame(width: 50, height: 50)
            .background(color)
            .cornerRadius(10)
            .padding(10)
            Text(label)
                .font(.subheadline)
        }
    }
}

