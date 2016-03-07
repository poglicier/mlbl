//
//  DataController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 05.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class DataController {
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("mlbl", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: [NSMigratePersistentStoresAutomaticallyOption : NSNumber(bool: true),
                NSInferMappingModelAutomaticallyOption : NSNumber(bool: true)])
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy private var privateContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    lazy var mainContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.parentContext = self.privateContext
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    private func saveContext(context: NSManagedObjectContext) {
        do {
            try context.save()
            if let parent = context.parentContext {
                parent.performBlock({ () -> Void in
                    do {
                        try parent.save()
                        if let grandParent = parent.parentContext {
                            grandParent.performBlock({ () -> Void in
                                do {
                                    try grandParent.save()
                                } catch {
                                    let nserror = error as NSError
                                    NSLog("Private Writer Unresolved error \(nserror), \(nserror.userInfo)")
                                }
                            })
                        }
                    } catch {
                        let nserror = error as NSError
                        NSLog("Main Context Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                })
            }
        } catch {}
    }
}