//
//  File.swift
//  
//
//  Created by Leonard Pries on 22.08.24.
//

import SwiftUI

public enum RecordingType: Codable {
    case basic
    case fixedLength(Int)  // Time in seconds
    
    public var localizedDescription: LocalizedStringKey {
        switch self {
        case .basic:
            "MICROPHONERECORDING_TYPE_BASIC"
        case .fixedLength:
            "MICROPHONERECORDING_TYPE_FIXEDLENGTH"
        }
    }
}
