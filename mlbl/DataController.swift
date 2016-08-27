//
//  DataController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 05.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class DataController {    
    private enum Method: String {
        case Regions = "GetRegions"
        case GameStats = "gameBoxScore"
    }
    
    private enum Keys: String {
        case Format = "format"
        case Json = "json"
    }
    
    lazy var language: String! = {
        var prefLanguage = NSLocale.preferredLanguages().first
        if prefLanguage == nil {
            prefLanguage = ""
        }
        return prefLanguage!
    }()
    
    private let mlblCompId = 9001
    private let queue = NSOperationQueue()
    private var privateContext: NSManagedObjectContext!
    private(set) var mainContext: NSManagedObjectContext!
    
    // MARK: - Public
    
    func currentCompetitionId() -> Int {
        let fetchRequest = NSFetchRequest(entityName: Competition.entityName())
        fetchRequest.predicate = NSPredicate(format: "isChoosen = true")
        do {
            if let comp = try self.mainContext.executeFetchRequest(fetchRequest).first as? Competition {
                return comp.objectId as! Int
            }
        } catch {}
        
        return 0
    }
    
    init () {
        self.privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        self.privateContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        self.mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        self.mainContext!.parentContext = self.privateContext
    }
    
    func getCompetitions(completion: (NSError? -> ())?) {
        let request = CompetitionsRequest(parentId: self.mlblCompId)
        request.dataController = self
        
        request.completionBlock = {
            dispatch_async(dispatch_get_main_queue(), {
                completion?(request.error)
            })
        }
        self.queue.addOperation(request)
    }
    
    func getGamesForDate(date: NSDate, completion: ((NSError?, prevDate: NSDate?, nextDate: NSDate?) -> ())?) {
        let request = GamesRequest(date: date, compId: self.currentCompetitionId())
        request.dataController = self
        
        request.completionBlock = {
            dispatch_async(dispatch_get_main_queue(), {
                completion?(request.error, prevDate: request.prevDate, nextDate: request.nextDate)
            })
        }
        self.queue.addOperation(request)
    }
    
    func getGameStats(gameId: Int, completion: (NSError? -> ())?) {
        let request = GameStatsRequest(gameId: gameId)
        request.dataController = self
        
        request.completionBlock = {
            dispatch_async(dispatch_get_main_queue(), {
                completion?(request.error)
            })
        }
        self.queue.addOperation(request)
    }
    
    func getPlayers(from: Int, count: Int, completion: ((NSError?, responseCount: Int) -> ())?) {
        let playersRequests = self.queue.operations.filter {$0 is PlayersRequest && !$0.cancelled} as! [PlayersRequest]
        let sameOperations = playersRequests.filter {$0.from == from && $0.count == count}
        
        if sameOperations.count > 0 {
            for sameOperation in sameOperations {
                sameOperation.completionBlock = {
                    dispatch_async(dispatch_get_main_queue(), {
                        completion?(sameOperation.error, responseCount: sameOperation.responseCount)
                    })
                }
            }
        } else {
            let request = PlayersRequest(from: from, count: count, compId: self.currentCompetitionId())
            request.dataController = self
            
            request.completionBlock = {
                dispatch_async(dispatch_get_main_queue(), {
                    completion?(request.error, responseCount: request.responseCount)
                })
            }
            self.queue.addOperation(request)
        }
    }
    
    func getStatParameters(completion: (NSError? -> ())?) {
        let request = StatParametersRequest()
        request.dataController = self
        
        request.completionBlock = {
            dispatch_async(dispatch_get_main_queue(), {
                completion?(request.error)
            })
        }
        self.queue.addOperation(request)
    }
    
    func getBestPlayers(paramId: Int, completion: ((NSError?, responseCount: Int) -> ())?) {
        let request = BestPlayersRequest(paramId: paramId, compId: self.currentCompetitionId())
        request.dataController = self
        
        request.completionBlock = {
            dispatch_async(dispatch_get_main_queue(), {
                completion?(request.error, responseCount: request.responseCount)
            })
        }
        self.queue.addOperation(request)
    }
    
    func searchPlayers(from: Int, count: Int, searchText: String, completion: ((NSError?, responseCount: Int) -> ())?) {
        let playersRequests = self.queue.operations.filter {$0 is PlayersRequest && !$0.cancelled} as! [PlayersRequest]
        let searchOperations = playersRequests.filter {$0.searchText != nil}
        for searchOperation in searchOperations {
            searchOperation.cancel()
        }
        
        let request = PlayersRequest(from: from, count: count, compId: self.currentCompetitionId(), searchText: searchText)
        request.dataController = self
        
        request.completionBlock = {
            dispatch_async(dispatch_get_main_queue(), {
                completion?(request.error, responseCount: request.responseCount)
            })
        }
        self.queue.addOperation(request)
    }
    
    func getRoundRobin(compId: Int, completion: (NSError? -> ())?) {
        let request = RoundRobinRequest(compId: compId)
        request.dataController = self
        
        request.completionBlock = {
            dispatch_async(dispatch_get_main_queue(), {
                completion?(request.error)
            })
        }
        self.queue.addOperation(request)
    }
    
    func getPlayoff(compId: Int, completion: (NSError? -> ())?) {
        let request = PlayoffRequest(compId: compId)
        request.dataController = self
        
        request.completionBlock = {
            dispatch_async(dispatch_get_main_queue(), {
                completion?(request.error)
            })
        }
        self.queue.addOperation(request)
    }
    
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
            
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            dict[NSUnderlyingErrorKey] = wrappedError
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext(context: NSManagedObjectContext) {
        context.performBlock {
            if context.hasChanges == true {
                do {
                    try context.save()
                    if let parent = context.parentContext {
                        self.saveContext(parent)
                    }
                } catch {
                    let nserror = error as NSError
                    NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
}