//
//  TeamGamesRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 03.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class TeamGamesRequest: NetworkRequest {
    private var compId: Int!
    private var teamId: Int!
    
    init(compId: Int, teamId: Int) {
        super.init()
        
        self.compId = compId
        self.teamId = teamId
    }
    
    override func start() {
        if cancelled {
            finished = true
            return
        }
        
        let urlString = "TeamGames/\(self.teamId)?compId=\(self.compId)&format=json"
        guard let url = NSURL(string: urlString, relativeToURL: self.baseUrl) else { fatalError("Failed to build URL") }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        if let _ = self.params {
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(self.params!, options: NSJSONWritingOptions.init(rawValue: 0))
            } catch {
                finished = true
                return
            }
        }
        
        self.sessionTask = localURLSession.dataTaskWithRequest(request)
        self.sessionTask?.resume()
    }
    
    override func processData() {
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(incomingData, options: .AllowFragments)
            if let gamesDicts = json as? [[String:AnyObject]] {
                let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                context.parentContext = self.dataController?.mainContext
                context.performBlockAndWait({
                    var gameIdsToSave = [NSNumber]()
                    for gameDict in gamesDicts {
                        let game = Game.gameWithDict(gameDict, inContext: context)
                        
                        if let gameId = game?.objectId {
                            gameIdsToSave.append(gameId)
                        }
                    }
                    
                    // Удаляем старые игры
                    let fetchRequest = NSFetchRequest(entityName: Game.entityName())
                    fetchRequest.predicate = NSPredicate(format: "teamAId = %d OR teamBId = %d", self.teamId, self.teamId)
                    do {
                        let all = try context.executeFetchRequest(fetchRequest) as! [Game]
                        for game in all {
                            if let gameId = game.objectId {
                                if gameIdsToSave.contains(gameId) == false {
                                    print("DELETE Game \(game.date)")
                                    context.deleteObject(game)
                                }
                            }
                        }
                    }
                    catch {}
                    
                    self.dataController?.saveContext(context)
                })
            } else {
                self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "json не является словарём"])
            }
        } catch {
            self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "Не смог разобрать json"])
        }
    }
}