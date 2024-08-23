//
//  File.swift
//  
//
//  Created by Leonard Pries on 22.08.24.
//

import Foundation

public struct RecordingModel: Codable, Equatable {
    public var subjectID: String = ""
    public var title: String = ""
    public var versionNumber: Int = 1
    
    public init(subjectID: String, title: String, versionNumber: Int) {
        self.subjectID = subjectID
        self.title = title
        self.versionNumber = versionNumber
    }
    
    public static func == (lhs: RecordingModel, rhs: RecordingModel) -> Bool {
        lhs.subjectID == rhs.subjectID
        && lhs.title == rhs.title
        && lhs.versionNumber == rhs.versionNumber
    }
    
    public func getFileUrl() -> String {
        var fileNameBase = subjectID + "_" + title
        
        fileNameBase = fileNameBase + "_" + String(versionNumber) + UUID().uuidString
        
        let fileName = fileNameBase + ".m4a"
        
        return fileName
    }
}
