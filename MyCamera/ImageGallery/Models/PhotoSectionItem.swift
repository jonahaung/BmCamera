//
//  PhotoSectionItem.swift
//  BmCamera
//
//  Created by Aung Ko Min on 27/3/21.
//

import Foundation

class PhotoSectionItem: ObservableObject, Identifiable, Equatable {

    var id: String { return date.description + photoItems.count.description}
    let date: Date
    @Published var show: Bool = false
    @Published var currentGrid = 2
    
    var photoItems: [PhotoItem]
    var headItem: PhotoItem? {
        return photoItems.first
    }
    
    init(date: Date, photoItems: [PhotoItem]) {
        self.date = date
        self.photoItems = photoItems
    }
    
    static func == (lhs: PhotoSectionItem, rhs: PhotoSectionItem) -> Bool {
        return lhs.id == rhs.id
    }
}
