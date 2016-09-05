//
//  PlayerTeamsRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 05.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class PlayerTeamsRequest: NetworkRequest {
    private var playerId: Int!
    
    init(playerId: Int) {
        super.init()
        
        self.playerId = playerId
    }
    
    override func start() {
        if cancelled {
            finished = true
            return
        }
        
        let urlString = "PlayerTeams/\(self.playerId)?format=json"
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
            if let seasonTeamsDicts = json as? [[String:AnyObject]] {
                let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                context.parentContext = self.dataController?.mainContext
                context.performBlockAndWait({
                    // У SeasonTeam нет идентификаторов, поэтому удаляем все
                    var fetchRequest = NSFetchRequest(entityName: SeasonTeam.entityName())
                    fetchRequest.predicate = NSPredicate(format: "player.objectId = %d", self.playerId)
                    do {
                        let all = try context.executeFetchRequest(fetchRequest) as! [SeasonTeam]
                        for seasonTeam in all {
                            print("DELETE SeasonTeam \(seasonTeam.team?.nameRu)")
                            context.deleteObject(seasonTeam)
                        }
                    }
                    catch {}
                    
                    var player: Player?
                    fetchRequest = NSFetchRequest(entityName: Player.entityName())
                    fetchRequest.predicate = NSPredicate(format: "objectId = %d", self.playerId)
                    do {
                        player = try context.executeFetchRequest(fetchRequest).first as? Player
                    } catch {}
                    
                    for seasonTeamDict in seasonTeamsDicts {
                        if let seasonTeam = SeasonTeam.seasonTeamWithDict(seasonTeamDict, inContext: context) {
                            seasonTeam.player = player
                        }
                    }
                    
                    self.dataController?.saveContext(context)
                })
            } else {
                self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "json не является массивом словарей"])
            }
        } catch {
            self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "Не смог разобрать json"])
        }
    }
}