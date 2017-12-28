//
//  DataController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 05.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class DataController {    
    fileprivate enum Method: String {
        case Regions = "GetRegions"
        case GameStats = "gameBoxScore"
    }
    
    fileprivate enum Keys: String {
        case Format = "format"
        case Json = "json"
    }
    
    lazy var language: String! = {
        var prefLanguage = Locale.preferredLanguages.first
        if prefLanguage == nil {
            prefLanguage = ""
        }
        return prefLanguage!
    }()
    
    fileprivate let queue = OperationQueue()
    fileprivate var privateContext: NSManagedObjectContext!
    fileprivate(set) var mainContext: NSManagedObjectContext!
    
    // MARK: - Public
    
    func currentCompetitionId() -> Int {
        let fetchRequest = NSFetchRequest<Competition>(entityName: Competition.entityName())
        fetchRequest.predicate = NSPredicate(format: "isChoosen = true")
        do {
            if let comp = try self.mainContext.fetch(fetchRequest).first {
                return comp.objectId as! Int
            }
        } catch {}
        
        return 0
    }
    
    init () {
        self.privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.privateContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        self.mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.mainContext!.parent = self.privateContext
    }
    
    func getCompetitions(parentCompId: Int?, completion: ((NSError?) -> ())?) {
        let request = CompetitionsRequest(parentId: parentCompId)
        request.dataController = self
        
        request.completionBlock = {
            DispatchQueue.main.async(execute: {
                completion?(request.error)
            })
        }
        self.queue.addOperation(request)
    }
    
    func getGamesForDate(_ date: Date, completion: ((NSError?, _ prevDate: Date?, _ nextDate: Date?) -> ())?) {
        let request = GamesRequest(date: date, compId: self.currentCompetitionId())
        request.dataController = self
        
        request.completionBlock = {
            DispatchQueue.main.async(execute: {
                completion?(request.error, request.prevDate, request.nextDate)
            })
        }
        self.queue.addOperation(request)
    }
    
    func getGamesOnlineStatuses(gameIds: [Int], completion: ((NSError?) -> ())?) {
        let request = OnlineStatusRequest(gameIds: gameIds)
        request.dataController = self
        
        request.completionBlock = {
            DispatchQueue.main.async(execute: {
                completion?(request.error)
            })
        }
        self.queue.addOperation(request)
    }
    
    func getGameStats(_ gameId: Int, completion: ((NSError?) -> ())?) {
        let request = GameStatsRequest(gameId: gameId)
        request.dataController = self
        
        request.completionBlock = {
            DispatchQueue.main.async(execute: {
                completion?(request.error)
            })
        }
        self.queue.addOperation(request)
    }
    
    func getPlayers(_ from: Int, count: Int, completion: ((NSError?, _ responseCount: Int) -> ())?) {
        let playersRequests = self.queue.operations.filter {$0 is PlayersRequest && !$0.isCancelled} as! [PlayersRequest]
        let sameOperations = playersRequests.filter {$0.from == from && $0.count == count}
        
        if sameOperations.count > 0 {
            for sameOperation in sameOperations {
                sameOperation.completionBlock = {
                    DispatchQueue.main.async(execute: {
                        completion?(sameOperation.error, sameOperation.responseCount)
                    })
                }
            }
        } else {
            let request = PlayersRequest(from: from, count: count, compId: self.currentCompetitionId())
            request.dataController = self
            
            request.completionBlock = {
                DispatchQueue.main.async(execute: {
                    completion?(request.error, request.responseCount)
                })
            }
            self.queue.addOperation(request)
        }
    }
    
    func getStatParameters(_ completion: ((NSError?) -> ())?) {
        let request = StatParametersRequest()
        request.dataController = self
        
        request.completionBlock = {
            DispatchQueue.main.async(execute: {
                completion?(request.error)
            })
        }
        self.queue.addOperation(request)
    }
    
    func getBestPlayers(_ paramId: Int, completion: ((NSError?, _ responseCount: Int) -> ())?) {
        let request = BestPlayersRequest(paramId: paramId, compId: self.currentCompetitionId())
        request.dataController = self
        
        request.completionBlock = {
            DispatchQueue.main.async(execute: {
                completion?(request.error, request.responseCount)
            })
        }
        self.queue.addOperation(request)
    }
    
    func searchPlayers(_ from: Int, count: Int, searchText: String, completion: ((NSError?, _ responseCount: Int) -> ())?) {
        let playersRequests = self.queue.operations.filter {$0 is PlayersRequest && !$0.isCancelled} as! [PlayersRequest]
        let searchOperations = playersRequests.filter {$0.searchText != nil}
        for searchOperation in searchOperations {
            searchOperation.cancel()
        }
        
        let request = PlayersRequest(from: from, count: count, compId: self.currentCompetitionId(), searchText: searchText)
        request.dataController = self
        
        request.completionBlock = {
            DispatchQueue.main.async(execute: {
                completion?(request.error, request.responseCount)
            })
        }
        self.queue.addOperation(request)
    }
    
    func getRoundRobin(_ compId: Int, completion: ((NSError?) -> ())?) {
        let request = RoundRobinRequest(compId: compId)
        request.dataController = self
        
        request.completionBlock = {
            DispatchQueue.main.async(execute: {
                completion?(request.error)
            })
        }
        self.queue.addOperation(request)
    }
    
    func getPlayoff(_ compId: Int, completion: ((NSError?) -> ())?) {
        let request = PlayoffRequest(compId: compId)
        request.dataController = self
        
        request.completionBlock = {
            DispatchQueue.main.async(execute: {
                completion?(request.error)
            })
        }
        self.queue.addOperation(request)
    }
    
    func getTeamInfo(_ compId: Int, teamId: Int, completion: ((NSError?) -> ())?) {
        let request = TeamInfoRequest(compId: compId, teamId: teamId)
        request.dataController = self
        
        request.completionBlock = {
            DispatchQueue.main.async(execute: {
                completion?(request.error)
            })
        }
        self.queue.addOperation(request)
    }
    
    func getTeamRoster(_ compId: Int, teamId: Int, completion: ((NSError?) -> ())?) {
        let request = TeamRosterRequest(compId: compId, teamId: teamId)
        request.dataController = self
        
        request.completionBlock = {
            DispatchQueue.main.async(execute: {
                completion?(request.error)
            })
        }
        self.queue.addOperation(request)
    }
    
    func getTeamGames(_ compId: Int, teamId: Int, completion: ((NSError?) -> ())?) {
        let request = TeamGamesRequest(compId: compId, teamId: teamId)
        request.dataController = self
        
        request.completionBlock = {
            DispatchQueue.main.async(execute: {
                completion?(request.error)
            })
        }
        self.queue.addOperation(request)
    }
    
    func getTeamStats(_ compId: Int, teamId: Int, completion: ((NSError?) -> ())?) {
        let request = TeamStatsRequest(compId: compId, teamId: teamId)
        request.dataController = self
        
        request.completionBlock = {
            DispatchQueue.main.async(execute: {
                completion?(request.error)
            })
        }
        self.queue.addOperation(request)
    }
    
    func getPlayerStats(_ compId: Int, playerId: Int, completion: ((NSError?) -> ())?) {
        let request = PlayerStatsRequest(compId: compId, playerId: playerId)
        request.dataController = self
        
        request.completionBlock = {
            DispatchQueue.main.async(execute: {
                completion?(request.error)
            })
        }
        self.queue.addOperation(request)
    }
    
    func getPlayerTeams(_ playerId: Int, completion: ((NSError?) -> ())?) {
        let request = PlayerTeamsRequest(playerId: playerId)
        request.dataController = self
        
        request.completionBlock = {
            DispatchQueue.main.async {
                completion?(request.error)
            }
        }
        self.queue.addOperation(request)
    }
    
    func sendAPNSToken(_ token: String, oldToken: String?, completion: ((NSError?) -> ())?) {
        let request = SendTokenRequest(token: token, oldToken: oldToken, compId: self.currentCompetitionId())
        request.dataController = self
        
        request.completionBlock = {
            DispatchQueue.main.async {
                completion?(request.error)
            }
        }
        self.queue.addOperation(request)
    }
    
    func getSubscriptionInfoFor(teamId: Int, completion: ((NSError?) -> ())?) {
        if let token = DefaultsController.shared.apnsToken {
            let request = SubscriptionInfoRequest(teamId: teamId, token: token)
            request.dataController = self
            
            request.completionBlock = {
                DispatchQueue.main.async {
                    completion?(request.error)
                }
            }
            self.queue.addOperation(request)
        } else {
            completion?(NSError(domain: "", code: 0, userInfo: nil))
        }
    }
    
    func subscribe(_ subscribe: Bool, onTeamWithId teamId: Int, completion: ((NSError?) -> ())?) {
        if let token = DefaultsController.shared.apnsToken {
            let request = SubscribeRequest(subscribe: subscribe, token: token, teamId: teamId)
            request.dataController = self
            
            request.completionBlock = {
                DispatchQueue.main.async {
                    completion?(request.error)
                }
            }
            self.queue.addOperation(request)
        } else {
            completion?(NSError(domain: "", code: 0, userInfo: nil))
        }
    }
    
    func terminateRequests() {
        self.queue.cancelAllOperations()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "mlbl", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption : NSNumber(value: true as Bool),
                NSInferMappingModelAutomaticallyOption : NSNumber(value: true as Bool)])
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
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
    
    func saveContext(_ context: NSManagedObjectContext) {
        context.perform {
            if context.hasChanges == true {
                do {
                    try context.save()
                    if let parent = context.parent {
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
