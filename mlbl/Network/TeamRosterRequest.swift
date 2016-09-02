//
//  TeamRosterRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 02.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class TeamRosterRequest: NetworkRequest {
    
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
        
        let urlString = "TeamRoster/\(self.teamId)?compId=\(self.compId)&format=json"
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
            if let playersDicts = json["Players"] as? [[String:AnyObject]] {
                let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                context.parentContext = self.dataController?.mainContext
                context.performBlockAndWait({
                    var team: Team?
                    var fetchRequest = NSFetchRequest(entityName: Team.entityName())
                    fetchRequest.predicate = NSPredicate(format: "objectId = %d", self.teamId)
                    do {
                        team = try context.executeFetchRequest(fetchRequest).first as? Team
                    } catch {}
                    
                    var playerIdsToSave = [NSNumber]()
                    for playerDict in playersDicts {
                        let player = Player.playerWithDict(playerDict, inContext: context)
                        player?.team = team
                        
                        if let playerId = player?.objectId {
                            playerIdsToSave.append(playerId)
                        }
                    }
                    
                    // Удаляем старых игроков
                    fetchRequest = NSFetchRequest(entityName: Player.entityName())
                    fetchRequest.predicate = NSPredicate(format: "team.objectId = %d", self.teamId)
                    do {
                        let all = try context.executeFetchRequest(fetchRequest) as! [Player]
                        for player in all {
                            if let playerId = player.objectId {
                                if playerIdsToSave.contains(playerId) == false {
                                    print("DELETE Player \(player.lastNameRu)")
                                    context.deleteObject(player)
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