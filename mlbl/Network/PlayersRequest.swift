//
//  PlayersRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 18.07.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class PlayersRequest: NetworkRequest {
    private let mlblTournamentId = 9001
    
    override func start() {
        if cancelled {
            finished = true
            return
        }
        // http://reg.infobasket.ru/Widget/CompGamePlayers/9001?search=зим&stats=1&skip=0&take=10
        guard let url = NSURL(string: "CompGamePlayers/\(self.mlblTournamentId)?skip=0&take=10", relativeToURL: self.baseUrl) else { fatalError("Failed to build URL") }
        
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
            if let playerDicts = json as? [[String:AnyObject]] {
                let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                context.parentContext = self.dataController?.mainContext
                context.performBlock({
                    var playerIdsToSave = [NSNumber]()
                    for playerDict in playerDicts {
                        let player = Player.playerWithDict(playerDict, inContext: context)
                        
                        if let playerId = player?.objectId {
                            playerIdsToSave.append(playerId)
                        }
                    }
                    
                    // Удаляем из Core Data игроков
//                    let fetchRequest = NSFetchRequest(entityName: Game.entityName())
//                    fetchRequest.predicate = NSPredicate(format: "date = %@", self.date)
//                    
//                    do {
//                        let all = try context.executeFetchRequest(fetchRequest) as! [Game]
//                        for game in all {
//                            if let gameId = game.objectId {
//                                if gameIdsToSave.contains(gameId) == false {
//                                    print("DELETE Game \(game.teamA?.nameRu):\(game.teamB?.nameRu)")
//                                    context.deleteObject(game)
//                                }
//                            }
//                        }
//                    }
//                    catch {}
                    
                    self.dataController?.saveContext(context)
                })
            } else {
                self.error = NSError(domain: "internal app error", code: -1, userInfo: [NSLocalizedDescriptionKey : "Обработка запроса не реализована"])
            }
        } catch {
            self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "Не смог разобрать json"])
        }
    }
}