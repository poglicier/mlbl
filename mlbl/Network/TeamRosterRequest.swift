//
//  TeamRosterRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 02.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class TeamRosterRequest: NetworkRequest {
    
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
        
        let urlString = "TeamRoster/\(self.teamId!)?compId=\(self.compId!)&format=json"
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
            if let playersDicts = (json as? [String:AnyObject])?["Players"] as? [[String:AnyObject]] {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                context.parent = self.dataController?.mainContext
                context.performAndWait({
                    var team: Team?
                    let fetchRequest = NSFetchRequest<Team>(entityName: Team.entityName())
                    fetchRequest.predicate = NSPredicate(format: "objectId = %d", self.teamId)
                    do {
                        team = try context.fetch(fetchRequest).first
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
                    let fetchRequestD = NSFetchRequest<Player>(entityName: Player.entityName())
                    fetchRequestD.predicate = NSPredicate(format: "team.objectId = %d", self.teamId)
                    do {
                        let all = try context.fetch(fetchRequestD)
                        for player in all {
                            if let playerId = player.objectId {
                                if playerIdsToSave.contains(playerId) == false {
                                    print("DELETE Player \(player.lastNameRu ?? "")")
                                    context.delete(player)
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
