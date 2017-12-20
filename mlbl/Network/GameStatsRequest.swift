//
//  GameStatsRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 07.07.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class GameStatsRequest: NetworkRequest {
    fileprivate var gameId: Int!
    
    init(gameId: Int) {
        super.init()
        
        self.gameId = gameId
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        guard let url = URL(string: "GameBoxScore/\(self.gameId!)?format=json", relativeTo: self.baseUrl as URL?) else { fatalError("Failed to build URL") }
        
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
        print(String(bytes: incomingData as Data, encoding: .utf8))
        do {
            let json = try JSONSerialization.jsonObject(with: incomingData as Data, options: .allowFragments)
            if let dict = json as? [String:AnyObject] {
                if (dict["Header"] as? String) == "Ошибка" {
                    let code = (dict["MessageType"] as? Int) ?? -1
                    
                    var userInfo: [String:AnyObject] = [:]
                    if let message = dict["Message"] as? String {
                        userInfo[NSLocalizedDescriptionKey] = message as AnyObject?
                    }
                    
                    self.error = NSError(domain: "Error", code: code, userInfo: userInfo)
                } else {
                    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                    context.parent = self.dataController?.mainContext
                    context.performAndWait({
                        // У статистики нет id, поэтому удалем все старые
                        let fetchRequest = NSFetchRequest<GameStatistics>(entityName: GameStatistics.entityName())
                        fetchRequest.predicate = NSPredicate(format: "game.objectId = %d", self.gameId)
                        do {
                            let all = try context.fetch(fetchRequest)
                            for stat in all {
                                print("DELETE GameStatistics \(stat.player?.lastNameRu ?? "")")
                                context.delete(stat)
                            }
                        }
                        catch {}
                        
                        Game.gameWithDict(dict, in: context)
                        self.dataController?.saveContext(context)
                    })
                }
            }
        } catch {
            self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "Не смог разобрать json"])
        }
    }
}
