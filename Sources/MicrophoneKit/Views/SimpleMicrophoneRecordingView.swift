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
    
    @State private var debugMode: Bool = false
    
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
                .font(.system(size: 50))
                .fontWeight(.semibold)
            
            Spacer()
            
            if debugMode {
                AudioWaveView(viewModel: $audioWaveViewModel)
            }
                
            Text(viewModel.timeFormatted)
                .font(.system(size: 48))
                .fontWeight(.medium)
                .fontDesign(.monospaced)
                .padding()
            
            Spacer()
            
            HStack {
                IconButton(
                    iconName: "arrow.clockwise",
                    label: "Nochmal",
                    color: .black,
                    action: {
                    viewModel.restart()
                })
                
                if (viewModel.audioStreamManager.audioStreamManagerState == .idle) {
                    IconButton(
                        iconName: "record.circle",
                        label: "Starten",
                        color: Color(red: 110 / 255, green: 186 / 255, blue: 180 / 255),
                        action: {
                        viewModel.startRecording()
                    })
                } else {
                    IconButton(
                        iconName: "stop.circle",
                        label: "Fertig",
                        color: Color(red: 227 / 255, green: 128 / 255, blue: 124 / 255),
                        action: {
                        viewModel.stopRecording()
                    })
                }
            }
            
            Spacer()
            
            instructionAction
        }
        .toolbar {
#if DEBUG
            Menu("Debug", systemImage: "hammer") {
                Toggle("Debug Mode", isOn: $debugMode)
            }
#endif
        }
    }
    
    @MainActor
    @ViewBuilder
    private var instructionAction: some View {
        Button {
            if (viewModel.audioStreamManager.audioStreamManagerState != .idle) {
                viewModel.stopRecording()
            }
            closeAction()
        } label: {
            Text("Weiter")
                .font(.title)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.blue, in: .rect(cornerRadius: 16))
                .foregroundStyle(.white)
        }
    }
}
