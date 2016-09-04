//
//  RoundRobinRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 23.08.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class RoundRobinRequest: NetworkRequest {
    
    private var compId: Int!
    
    init(compId: Int) {
        super.init()
        
        self.compId = compId
    }
    
    override func start() {
        if cancelled {
            finished = true
            return
        }
        
        let urlString = "RoundRobin/\(self.compId)?format=json"
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
            if json is [String:AnyObject] {
                let errorMesage = json["Message"] as? String
                self.error = NSError(domain: "internal app error", code: -1, userInfo: [NSLocalizedDescriptionKey : errorMesage ?? "unknown error"])
            } else if let teamRoundRankDicts = json as? [[String:AnyObject]] {
                let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                context.parentContext = self.dataController?.mainContext
                context.performBlockAndWait({
                    // Удаляем старую турнирную таблицу
                    let fetchRequest = NSFetchRequest(entityName: TeamRoundRank.entityName())
                    fetchRequest.predicate = NSPredicate(format: "competition.objectId = %d", self.compId)
                    do {
                        let all = try context.executeFetchRequest(fetchRequest) as! [TeamRoundRank]
                        for rank in all {
                            print("DELETE TeamRoundRank \(rank.team?.nameRu)")
                            context.deleteObject(rank)
                        }
                    }
                    catch {}
                    
                    for teamRoundRankDict in teamRoundRankDicts {
                        TeamRoundRank.rankWithDict(teamRoundRankDict, compId: self.compId, inContext: context)
                    }
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