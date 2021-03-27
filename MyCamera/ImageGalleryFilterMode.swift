//
//  ImageGalleryFilterMode.swift
//  BmCamera
//
//  Created by Aung Ko Min on 27/3/21.
//

import Foundation

enum ImageGalleryFilterMode: Identifiable, CaseIterable {
    var id: ImageGalleryFilterMode { return self }
    case favourite, video, photo, all
    
    var description: String {
        switch self {
        case .favourite:
            return "Favourites"
        case .video:
            return "Videos"
        case .photo:
            return "Photos"
        case .all:
            return "All Items"
        }
    }
}
