//
//  CoreDataContextObserver.swift
//  BmCamera
//
//  Created by Aung Ko Min on 27/3/21.
//

import Foundation
import CoreData

public struct CoreDataContextObserverState: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public static let inserted    = CoreDataContextObserverState(rawValue: 1 << 0)
    public static let updated = CoreDataContextObserverState(rawValue: 1 << 1)
    public static let deleted   = CoreDataContextObserverState(rawValue: 1 << 2)
    public static let refreshed   = CoreDataContextObserverState(rawValue: 1 << 3)
    public static let all: CoreDataContextObserverState  = [inserted, updated, deleted, refreshed]
}

public enum CoreDataObserverObjectChange {
    case updated(NSManagedObject)
    case refreshed(NSManagedObject)
    case inserted(NSManagedObject)
    case deleted(NSManagedObject)
    
    public func managedObject() -> NSManagedObject {
        switch self {
            case let .updated(value): return value
            case let .inserted(value): return value
            case let .refreshed(value): return value
            case let .deleted(value): return value
        }
    }
}

public struct CoreDataObserverAction {
    var state: CoreDataContextObserverState
    var completionBlock: CoreDataContextObserver.CompletionBlock
}

public class CoreDataContextObserver {
    public typealias CompletionBlock = (NSManagedObject, CoreDataContextObserverState) -> ()
    public typealias ContextChangeBlock = (_ notification: NSNotification, _ changedObjects: [CoreDataObserverObjectChange]) -> ()

    public var enabled: Bool = true
    public var contextChangeBlock: CoreDataContextObserver.ContextChangeBlock?
    
    private var notificationObserver: NSObjectProtocol?
    private(set) var context: NSManagedObjectContext
    private(set) var actionsForManagedObjectID = Dictionary<NSManagedObjectID, [CoreDataObserverAction]>()
    private(set) weak var persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    deinit {
        unobserveAllObjects()
        if let notificationObserver = notificationObserver {
            NotificationCenter.default.removeObserver(notificationObserver)
        }
    }
    
    public init(context: NSManagedObjectContext) {
        self.context = context
        self.persistentStoreCoordinator = context.persistentStoreCoordinator
        notificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context, queue: nil, using: { notification in
            self.handleContextObjectDidChangeNotification(notification: notification as NSNotification)
        })
    }
    
    private func handleContextObjectDidChangeNotification(notification: NSNotification) {
        guard let incomingContext = notification.object as? NSManagedObjectContext,
            let persistentStoreCoordinator = persistentStoreCoordinator,
            let incomingPersistentStoreCoordinator = incomingContext.persistentStoreCoordinator,
            enabled && persistentStoreCoordinator == incomingPersistentStoreCoordinator else {
            return
        }

        let insertedObjectsSet = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? Set<NSManagedObject>()
        let updatedObjectsSet = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? Set<NSManagedObject>()
        let deletedObjectsSet = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? Set<NSManagedObject>()
        let refreshedObjectsSet = notification.userInfo?[NSRefreshedObjectsKey] as? Set<NSManagedObject> ?? Set<NSManagedObject>()
        
        var combinedObjectChanges = insertedObjectsSet.map({ CoreDataObserverObjectChange.inserted($0) })
        combinedObjectChanges += updatedObjectsSet.map({ CoreDataObserverObjectChange.updated($0) })
        combinedObjectChanges += deletedObjectsSet.map({ CoreDataObserverObjectChange.deleted($0) })
        combinedObjectChanges += refreshedObjectsSet.map({ CoreDataObserverObjectChange.refreshed($0) })

        contextChangeBlock?(notification, combinedObjectChanges)
        
        let combinedSet = insertedObjectsSet.union(updatedObjectsSet).union(deletedObjectsSet)
        let allObjectIDs = Array(actionsForManagedObjectID.keys)
        let filteredObjects = combinedSet.filter({ allObjectIDs.contains($0.objectID) })
        
        for object in filteredObjects {
            guard let actionsForObject = actionsForManagedObjectID[object.objectID] else { continue }

            for action in actionsForObject {
                if action.state.contains(.inserted) && insertedObjectsSet.contains(object) {
                    action.completionBlock(object, .inserted)
                } else if action.state.contains(.updated) && updatedObjectsSet.contains(object) {
                    action.completionBlock(object, .updated)
                } else if action.state.contains(.deleted) && deletedObjectsSet.contains(object) {
                    action.completionBlock(object, .deleted)
                } else if action.state.contains(.refreshed) && refreshedObjectsSet.contains(object) {
                    action.completionBlock(object, .refreshed)
                }
            }
        }
    }
    
    public func observeObject(object: NSManagedObject, state: CoreDataContextObserverState = .all, completionBlock: @escaping CoreDataContextObserver.CompletionBlock) {
        let action = CoreDataObserverAction(state: state, completionBlock: completionBlock)
        if var actionArray = actionsForManagedObjectID[object.objectID] {
            actionArray.append(action)
            actionsForManagedObjectID[object.objectID] = actionArray
        } else {
            actionsForManagedObjectID[object.objectID] = [action]
        }
        
    }
    
    public func unobserveObject(object: NSManagedObject, forState state: CoreDataContextObserverState = .all) {
        if state == .all {
            actionsForManagedObjectID.removeValue(forKey: object.objectID)
        } else if let actionsForObject = actionsForManagedObjectID[object.objectID] {
            actionsForManagedObjectID[object.objectID] = actionsForObject.filter({ !$0.state.contains(state) })
        }
    }
    
    public func unobserveAllObjects() {
        actionsForManagedObjectID.removeAll()
    }
}
