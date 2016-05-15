//
//  CoreDataStack.swift
//  Photorama
//
//  Created by Richard Reed on 5/14/16.
//  Copyright © 2016 Richard Reed. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    let managedObjectModelName: String
    
    // read the model file from the main bundle
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(self.managedObjectModelName, withExtension: "momd")!
            return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    // set up the persistent store coordinator.
    private var applicationDocumentsDictionary: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls.first!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        var coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let pathComponent = "\(self.managedObjectModelName).sqlite"
        let url = self.applicationDocumentsDictionary.URLByAppendingPathComponent(pathComponent)
        let store = try! coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        return coordinator
    }()
    
    
    // ManagedObjectContext is the portal through which you interact with your entities
    lazy var mainQueueContext: NSManagedObjectContext = {
       let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        moc.name = "Main Queue Context (UI Context)"
        return moc
    }()
    
    
    required init(modelName: String) {
        managedObjectModelName = modelName
    }
    
    // save changes to the context
    func saveChanges() throws {
        var error: ErrorType?
        mainQueueContext.performBlockAndWait { 
            if self.mainQueueContext.hasChanges {
                do {
                    try self.mainQueueContext.save()
                }
                catch let saveError {
                    error = saveError
                }
            }
        }
        if let error = error {
            throw error
        }
    }
    
}