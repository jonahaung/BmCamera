//
//  Persistence.swift
//  MyanScan
//
//  Created by Aung Ko Min on 16/12/20.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
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
    func deleteAll() {
        AlertPresenter.show(title: "Are you sure to clear all albums") { sure in
            if sure {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Photo")
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try container.persistentStoreCoordinator.execute(deleteRequest, with: container.viewContext)
                    
                    UserdefaultManager.shared.passWords.forEach{ folderName in
                        let fileManager = FileManager.default
                        let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let diskCacheStorageBaseUrl = myDocuments.appendingPathComponent(folderName)
                        do {
                            let filePaths = try fileManager.contentsOfDirectory(at: diskCacheStorageBaseUrl, includingPropertiesForKeys: nil, options: [])
                            
                            for filePath in filePaths {
                                do {
                                    try fileManager.removeItem(at: filePath)
                                } catch {
                                    AlertPresenter.show(title: error.localizedDescription)
                                }
                            }
                            
                        } catch {
                            AlertPresenter.show(title: error.localizedDescription)
                        }
                        
                        AlertPresenter.show(title: "\(folderName) cleared")
                    }
                } catch {
                    AlertPresenter.show(title: error.localizedDescription)
                }
            }
        }
        
        
    }
}

