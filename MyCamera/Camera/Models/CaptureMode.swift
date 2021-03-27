//
//  CaptureMode.swift
//  MyCamera
//
//  Created by Aung Ko Min on 16/3/21.
//

import Foundation
enum CaptureMode: CaseIterable {
    
    case photo, movie
    
    var name: String {
        switch self {
        case .movie:
            return "Movie"
        case .photo:
            return "Photo"
        }
    }
    
    var imageName: String {
        switch self {
        case .movie:
            return "video.fill"
        case .photo:
            return "camera.fill"
        }
    }
    var captureButtonImageName: String {
        switch self {
        case .movie:
            return "video.fill"
        case .photo:
            return "camera.fill"
        }
    }
    func toggle() -> CaptureMode {
        switch self {
        case .photo:
            return .movie
        case .movie:
            return .photo
        }
    }
}
