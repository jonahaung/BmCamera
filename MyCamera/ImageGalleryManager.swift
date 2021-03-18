//
//  ImageGalleryManager.swift
//  MyCamera
//
//  Created by Aung Ko Min on 19/3/21.
//

import Foundation
import CoreData

class ImageGalleryManager: ObservableObject {
    
    struct Section: Identifiable, Equatable {
        var id: String { return date.description + photos.count.description }
        let date: Date
        let photos: [Photo]
        
        
    }
    
    var photos = [Photo]() {
        didSet {
            guard oldValue != photos else { return }
            updateSections()
        }
    }
    
    var sections = [Section]()
    
    
    init() {
        addObservers()
    }
    deinit {
        removeObservers()
        print("Gallery Deinit")
    }
    
    func fetchPhoto() {
        let folerName = UserdefaultManager.shared.currentFolderName ?? ""
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.fetchBatchSize = 20
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false), NSSortDescriptor(key: "date", ascending: false)]
        request.predicate = NSPredicate(format: "userId == %@", folerName)
        
        let context = PersistenceController.shared.container.viewContext
        
        do {
            self.photos = try context.fetch(request)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func updateSections() {
        sections.removeAll()
        let groupsArray = self.photos.groupSort(ascending: false, byDate: { $0.date!})
        groupsArray.forEach {
            if let date = $0.first?.date {
                self.sections.append(Section(date: date, photos: $0))
            }
        }
        objectWillChange.send()
    }
    
    private func addObservers() {
        // Observers when a context has been saved
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.contextSave(_ :)),
                                               name: NSNotification.Name.NSManagedObjectContextDidSave,
                                               object: nil)


        
    }
    private func removeObservers() {
        // Observers when a context has been saved
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
        
    }
    @objc private func contextSave(_ notification: Notification) {
        // Retrieves the context saved from the notification
           guard let context = notification.object as? NSManagedObjectContext else { return }

           // Checks if the parent context is the main one
        if context === PersistenceController.shared.container.viewContext {

            fetchPhoto()
        }
        
    }
}


extension Sequence {
    func groupSort(ascending: Bool = true, byDate dateKey: (Iterator.Element) -> Date) -> [[Iterator.Element]] {
        var categories: [[Iterator.Element]] = []
        for element in self {
            let key = dateKey(element)
            guard let dayIndex = categories.firstIndex(where: { $0.contains(where: { Calendar.current.isDate(dateKey($0), inSameDayAs: key) }) }) else {
                guard let nextIndex = categories.firstIndex(where: { $0.contains(where: { dateKey($0).compare(key) == (ascending ? .orderedDescending : .orderedAscending) }) }) else {
                    categories.append([element])
                    continue
                }
                categories.insert([element], at: nextIndex)
                continue
            }

            guard let nextIndex = categories[dayIndex].firstIndex(where: { dateKey($0).compare(key) == (ascending ? .orderedDescending : .orderedAscending) }) else {
                categories[dayIndex].append(element)
                continue
            }
            categories[dayIndex].insert(element, at: nextIndex)
        }
        return categories
    }
}


