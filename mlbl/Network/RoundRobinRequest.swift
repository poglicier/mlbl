//
//  RoundRobinRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 23.08.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class RoundRobinRequest: NetworkRequest {
    
    fileprivate var compId: Int!
    
    init(compId: Int) {
        super.init()
        
        self.compId = compId
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        let urlString = "RoundRobin/\(self.compId!)?format=json"
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
            if json is [String:AnyObject] {
                let errorMesage = (json as! [String:AnyObject])["Message"] as? String
                self.error = NSError(domain: "internal app error", code: -1, userInfo: [NSLocalizedDescriptionKey : errorMesage ?? "unknown error"])
            } else if let teamRoundRankDicts = json as? [[String:AnyObject]] {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                context.parent = self.dataController?.mainContext
                context.performAndWait({
                    // Удаляем старую турнирную таблицу
                    let fetchRequest = NSFetchRequest<TeamRoundRank>(entityName: TeamRoundRank.entityName())
                    fetchRequest.predicate = NSPredicate(format: "competition.objectId = %d", self.compId)
                    do {
                        let all = try context.fetch(fetchRequest)
                        for rank in all {
                            print("DELETE TeamRoundRank \(rank.team?.nameRu)")
                            context.delete(rank)
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
