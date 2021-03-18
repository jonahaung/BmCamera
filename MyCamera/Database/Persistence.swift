//
//  Persistence.swift
//  MyanScan
//
//  Created by Aung Ko Min on 16/12/20.
//

import CoreData
import UIKit
import AVFoundation

struct PersistenceController {
    static let shared = PersistenceController()

//    static var preview: PersistenceController = {
//        let result = PersistenceController(inMemory: true)
//        let viewContext = result.container.viewContext
//        for _ in 0..<10 {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//        }
//        do {
//            try viewContext.save()
//        } catch {
//            // Replace this implementation with code to handle the error appropriately.
//            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
//        return result
//    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "MyCamera")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    func save() {
        let viewContext = PersistenceController.shared.container.viewContext
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

extension Photo {
    
    static func create(data: Data, isVideo: Bool) -> Photo? {
        
        
        let id = UUID()
        
        guard let folerName = UserdefaultManager.shared.currentFolderName else {
            return nil
        }
        let context = PersistenceController.shared.container.viewContext
        let photo = Photo(context: context)
        photo.userId = folerName
        photo.id = id
        photo.date = Date()
        photo.isVideo = isVideo
        
        guard let url = photo.mediaUrl else { return nil}
        do {
            try data.write(to: url)
        } catch {
            print(error.localizedDescription)
        }
        PersistenceController.shared.save()
        
        return context.object(with: photo.objectID) as? Photo
    }
    var mediaUrl: URL? {
        guard let id = id?.uuidString else { return nil }
        let imageName = isVideo ? "/\(id).mov" : "/\(id).jpg"
        guard let folderUrl = Utils.getCurrentFolderUrl() else { return nil }
        let url = folderUrl.appendingPathComponent(imageName)
        return URL(fileURLWithPath: url.path)
    }
    func image() -> UIImage? {
        guard let url = mediaUrl else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    static var allFetchRequest: NSFetchRequest<Photo> {
        let folerName = UserdefaultManager.shared.currentFolderName ?? ""
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.predicate = NSPredicate(format: "userId == %@", folerName)
        return request
      }
    
    static func delete(photo: Photo) {
        
        let fileManager = FileManager.default
        guard let url = photo.mediaUrl else { return }
        if fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(atPath: url.path)
            }catch {
                print(error)
            }
            
        } else {
            print("File does not exist")
        }
        PersistenceController.shared.container.viewContext.delete(photo)
        PersistenceController.shared.save()
    }
    
    static func fetch(for folderName: String) -> [Photo]{
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.predicate = NSPredicate(format: "userId == %@", folderName)
        
        let context = PersistenceController.shared.container.viewContext
        
        do {
            return try context.fetch(request)
        } catch {
            print(error)
            return []
        }
    }
}
