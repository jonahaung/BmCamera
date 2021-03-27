//
//  PhotoItem.swift
//  BmCamera
//
//  Created by Aung Ko Min on 27/3/21.
//

import UIKit

class PhotoItem: ObservableObject, Identifiable, Equatable {
    
    let id: UUID?
    let photo: Photo
    
    private weak var observer: CoreDataContextObserver?

    @Published var isFavourite = false
    @Published var isSelected = false
    @Published var thumbnil: UIImage?
    
    var isVideo: Bool { return photo.isVideo }
    
    init(photo: Photo, observer: CoreDataContextObserver?) {
        id = photo.id
        isFavourite = photo.isFavourite
        self.photo = photo
        self.observer = observer
        thumbnil = photo.thumbnil ?? UIImage()
        
        self.observer?.observeObject(object: photo, completionBlock: { [weak self] (object, state) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch state {
                case .deleted:
                    self.thumbnil = nil
                case .updated:
                    guard let photo = object as? Photo else { return }
                    self.isFavourite = photo.isFavourite
                default:
                    break
                }
            }
        })
    }
    

    static func == (lhs: PhotoItem, rhs: PhotoItem) -> Bool {
        return lhs.id == rhs.id
    }
}
