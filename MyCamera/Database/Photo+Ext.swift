//
//  Photo+Ext.swift
//  MyCamera
//
//  Created by Aung Ko Min on 25/3/21.
//

import CoreData
import UIKit

extension Photo {
    
    var thumbnil: UIImage? {
        guard let data = thumbnilData else { return nil }
        return UIImage(data: data)
    }
    
    var mediaUrl: URL? {
        guard let id = id?.uuidString, let folderName = userId else { return nil }
        let imageName = isVideo ? "/\(id).mov" : "/\(id).jpg"
        guard let folderUrl = FileManagerDefault.shared.getCurrentFolderUrl(for: folderName) else { return nil }
        let url = folderUrl.appendingPathComponent(imageName)
        return URL(fileURLWithPath: url.path)
    }
    
    var originalImage: UIImage? {
        guard let url = mediaUrl else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
    
}


extension Photo {
    
    static func create(data: Data, isVideo: Bool) -> Photo? {
        guard let folerName = UserdefaultManager.shared.currentFolderName else {
            return nil
        }
        
        let id = UUID()
        
        let context = PersistenceController.shared.container.viewContext
        let photo = Photo(context: context)
        photo.id = id
        photo.userId = folerName
        photo.date = Date()
        photo.isVideo = isVideo
        
        guard let url = photo.mediaUrl else { return nil}
        
        do {
            try data.write(to: url)
            
            photo.fileSize = Int64(data.count)
            
            let thumbnil = photo.getThumbnilImage(mediaUrl: url)
            if let data = thumbnil?.jpegData(compressionQuality: 1) {
                photo.thumbnilData = data
            }
            
            try context.save()
            
            return context.object(with: photo.objectID) as? Photo
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    
    static func create(id: UUID, isVideo: Bool) -> Photo? {
    
        guard let folerName = UserdefaultManager.shared.currentFolderName else {
            return nil
        }
        let context = PersistenceController.shared.container.viewContext
        let photo = Photo(context: context)
        photo.id = id
        photo.userId = folerName
        photo.date = Date()
        photo.isVideo = isVideo
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        
        return context.object(with: photo.objectID) as? Photo
    }
    

    private func getThumbnilImage(mediaUrl: URL) -> UIImage? {
        if isVideo {
            return mediaUrl.videoThumbnil
        }else {
            return self.originalImage?.getThumbnail()
        }
    }
    
    
    
    static var allFetchRequest: NSFetchRequest<Photo> {
        let folerName = UserdefaultManager.shared.currentFolderName ?? ""
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.fetchBatchSize = 20
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
        let context = PersistenceController.shared.container.viewContext
        if context.hasChanges {
            try? context.save()
        }
        context.delete(photo)
        try? context.save()
    }
    
    static func fetch(for folderName: String) -> [Photo]{
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.includesPendingChanges = false
//        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
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

