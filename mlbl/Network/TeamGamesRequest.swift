//
//  TeamGamesRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 03.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class TeamGamesRequest: NetworkRequest {
    fileprivate var compId: Int!
    fileprivate var teamId: Int!
    
    init(compId: Int, teamId: Int) {
        super.init()
        
        self.compId = compId
        self.teamId = teamId
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        let urlString = "TeamGames/\(self.teamId!)?compId=\(self.compId!)&format=json"
        guard let url = URL(string: urlString, relativeTo: self.baseUrl as URL?) else { fatalError("Failed to build URL") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let _ = self.params {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: self.params!, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            } catch {
                isFinished = true
                return
            }
        }
        
        self.sessionTask = localURLSession.dataTask(with: request)
        self.sessionTask?.resume()
    }
    
    override func processData() {
        do {
            let json = try JSONSerialization.jsonObject(with: incomingData as Data, options: .allowFragments)
            if let gamesDicts = json as? [[String:AnyObject]] {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                context.parent = self.dataController?.mainContext
                context.performAndWait({
                    var gameIdsToSave = [NSNumber]()
                    for gameDict in gamesDicts {
                        let game = Game.gameWithDict(gameDict, inContext: context)
                        
                        if let gameId = game?.objectId {
                            gameIdsToSave.append(gameId)
                        }
                    }
                    
                    // Удаляем старые игры
                    let fetchRequest = NSFetchRequest<Game>(entityName: Game.entityName())
                    fetchRequest.predicate = NSPredicate(format: "teamAId = %d OR teamBId = %d", self.teamId, self.teamId)
                    do {
                        let all = try context.fetch(fetchRequest)
                        for game in all {
                            if let gameId = game.objectId {
                                if gameIdsToSave.contains(gameId) == false {
                                    print("DELETE Game \(game.date)")
                                    context.delete(game)
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
