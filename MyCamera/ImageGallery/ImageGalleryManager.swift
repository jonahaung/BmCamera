//
//  ImageGalleryManager.swift
//  MyCamera
//
//  Created by Aung Ko Min on 26/3/21.
//

import Foundation
import UIKit

class ImageGalleryManager: ObservableObject {

    var folderName: String?
    var sections = [PhotoSectionItem]()
    var selectedPhoto: Photo?
    
    @Published var selectedItems: [PhotoItem] = []
    
    private var photos = [Photo]()
    private var observer: CoreDataContextObserver?
    
    init() {
        observer = CoreDataContextObserver(context: PersistenceController.shared.container.viewContext)
        observer?.contextChangeBlock = { [weak self] _, changes in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                var canReload = false
                changes.forEach{
                    switch $0 {
                    case .inserted(let object):
                        guard let photo = PersistenceController.shared.container.viewContext.object(with: object.objectID) as? Photo else { return }
                        self.photos.append(photo)
                        canReload = true
                    default:
                        break
                    }
                }
                if canReload {
                    self.makeGroupSections(photos: self.photos)
                }
                
            }
        }
    }
    
    
    deinit {
        clear()
        print("Gallery Manager")
    }
    
    func clear() {
        observer?.unobserveAllObjects()
        observer = nil
        photos.removeAll()
        sections.removeAll()
        print("Cleared")
    }
    
    func fetchPhotos(filterMode: ImageGalleryFilterMode) {
        guard let folderName = folderName else { return }
        
        let photos = Photo.fetch(for: folderName)
        switch filterMode {
        case .all:
            self.photos = photos
        case .favourite:
            self.photos = photos.filter{ $0.isFavourite }
        case .video:
            self.photos = photos.filter{ $0.isVideo }
        case .photo:
            self.photos = photos.filter{ $0.isVideo == false }
        }
        
        makeGroupSections(photos: self.photos)
    }
    
    private func makeGroupSections(photos: [Photo]) {
        let groupsArray = photos.filter{ $0.date != nil }.groupSort(ascending: false, byDate: { $0.date!})
        var newSections = [PhotoSectionItem]()
        for (i, group) in groupsArray.enumerated() {
            if let date = group.first?.date {
                let section = PhotoSectionItem(date: date, photoItems: group.map{ PhotoItem(photo: $0, observer: observer) })
                if i == 0 {
                    section.show = true
                }
                newSections.append(section)
            }
        }
        
        sections = newSections
        objectWillChange.send()
    }
    
}
