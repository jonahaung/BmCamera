//
//  ImageGalleryManager.swift
//  MyCamera
//
//  Created by Aung Ko Min on 26/3/21.
//

import Foundation
import CoreData

class ImageGalleryManager: ObservableObject {
    
    struct SectionItem: Identifiable, Equatable {
        
        let id: String
        let date: Date
        let photos: [Photo]
        
        init(date: Date, photos: [Photo]) {
            self.date = date
            self.photos = photos
            self.id = date.description + photos.count.description
        }
        var show: Bool = false
        mutating func setShow(_show: Bool) {
            show = _show
        }
    }
    
    enum FilterMode: Identifiable {
        var id: FilterMode { return self }
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
    var filterMode = FilterMode.all
    var folderName: String?
    var sections = [SectionItem]()
    var selectedPhotos = [Photo]()
    var selectedPhoto: Photo?
    
    deinit {
        sections.removeAll()
        selectedPhotos.removeAll()
        print("Gallery Manager")
    }
    
    func fetchPhotos() {
        guard let folderName = folderName else { return }
        
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        var predicates = [NSPredicate(format: "userId == %@", folderName)]
        switch filterMode {
        case .all:
            break
        case .favourite:
            let predicate = NSPredicate(format: "isFavourite == %@", NSNumber(value: true))
            predicates.append(predicate)
        case .video:
            let predicate = NSPredicate(format: "isVideo == %@", NSNumber(value: true))
            predicates.append(predicate)
        case .photo:
            let predicate = NSPredicate(format: "isVideo == %@", NSNumber(value: false))
            predicates.append(predicate)
        
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        sections.removeAll()
        do {
            let photos = try PersistenceController.shared.container.viewContext.fetch(request)
            var sections = [SectionItem]()
            let groupsArray = photos.filter{ $0.date != nil }.groupSort(ascending: false, byDate: { $0.date!})
            
            for group in groupsArray {
                if let date = group.first?.date {
                    var section = SectionItem(date: date, photos: group)
                    if group == groupsArray.first {
                        section.setShow(_show: true)
                    }
                    sections.append(section)
                }
            }
            self.sections = sections
            self.objectWillChange.send()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func toggleSelect(photo: Photo) {
        
        SoundManager.vibrate(vibration: .selection)
        if selectedPhotos.contains(photo) {
            if let index = selectedPhotos.firstIndex(of: photo) {
                selectedPhotos.remove(at: index)
            }
        } else {
            selectedPhotos.append(photo)
        }
        objectWillChange.send()
    }
}
