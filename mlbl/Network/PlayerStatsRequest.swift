//
//  PlayerStatsRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 27.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class PlayerStatsRequest: NetworkRequest {
    fileprivate var playerId: Int!
    fileprivate var compId: Int!
    
    init(compId: Int, playerId: Int) {
        super.init()
        
        self.compId = compId
        self.playerId = playerId
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        let urlString = "PlayerStats/\(self.playerId!)?compID=\(self.compId!)&format=json"
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
            if let playerStatisticsDict = json as? [String:AnyObject] {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                context.parent = self.dataController?.mainContext
                context.performAndWait({
                    // У PlayersStatistics нет идентификаторов, поэтому удаляем все
                    let fetchRequest = NSFetchRequest<PlayerStatistics>(entityName: PlayerStatistics.entityName())
                    fetchRequest.predicate = NSPredicate(format: "player.objectId = %d", self.playerId)
                    do {
                        let all = try context.fetch(fetchRequest)
                        for playerStatistics in all {
                            print("DELETE PlayerStatistics \(playerStatistics.player?.lastNameRu)")
                            context.delete(playerStatistics)
                        }
                    }
                    catch {}
                    
                    PlayerStatistics.playerStatisticsWithDict(playerStatisticsDict, playerId: self.playerId, in: context)
                    
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
