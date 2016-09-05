//
//  GameStatsRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 07.07.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class GameStatsRequest: NetworkRequest {
    private var gameId: Int!
    
    init(gameId: Int) {
        super.init()
        
        self.gameId = gameId
    }
    
    override func start() {
        if cancelled {
            finished = true
            return
        }
        
        guard let url = NSURL(string: "GameBoxScore/\(self.gameId)?format=json", relativeToURL: self.baseUrl) else { fatalError("Failed to build URL") }
        
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
            if let dict = json as? [String:AnyObject] {
                if (dict["Header"] as? String) == "Ошибка" {
                    let code = (dict["MessageType"] as? Int) ?? -1
                    
                    var userInfo: [String:AnyObject] = [:]
                    if let message = dict["Message"] as? String {
                        userInfo[NSLocalizedDescriptionKey] = message
                    }
                    
                    self.error = NSError(domain: "Error", code: code, userInfo: userInfo)
                } else {
                    let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                    context.parentContext = self.dataController?.mainContext
                    context.performBlockAndWait({
                        // У статистики нет id, поэтому удалем все старые
                        let fetchRequest = NSFetchRequest(entityName: GameStatistics.entityName())
                        fetchRequest.predicate = NSPredicate(format: "game.objectId = %d", self.gameId)
                        do {
                            let all = try context.executeFetchRequest(fetchRequest) as! [GameStatistics]
                            for stat in all {
                                print("DELETE GameStatistics \(stat.game?.date)")
                                context.deleteObject(stat)
                            }
                        }
                        catch {}
                        
                        Game.gameWithDict(dict, inContext: context)
                        self.dataController?.saveContext(context)
                    })
                }
            }
        } catch {
            self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "Не смог разобрать json"])
        }
    }
}