//
//  AudioAuthorization.swift
//  thesis_voice_24
//
//  Created by Leonard Pries on 13.06.24.
//

import AVFoundation
import Foundation

final class AudioAuthorization {
    static var isAuthorized: Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        return status == .authorized
    }

    static var awaitAuthorization: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .audio)
            var isAuthorized = status == .authorized
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .audio)
            }
            return isAuthorized
        }
    }
}
