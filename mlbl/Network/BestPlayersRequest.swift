//
//  BestPlayersRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 17.08.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class BestPlayersRequest: NetworkRequest {
    private var compId: Int!
    private var paramId: Int!
    private(set) var responseCount = 0
    
    init(paramId: Int, compId: Int, searchText: String? = nil) {
        super.init()
        
        self.compId = compId
        self.paramId = paramId
    }
    
    override func start() {
        if cancelled {
            finished = true
            return
        }
        
        let urlString = "BestPlayers/\(self.compId)?param=\(self.paramId)&format=json"
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
            if let ranksDicts = json as? [[String:AnyObject]] {
                let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                context.parentContext = self.dataController?.mainContext
                context.performBlockAndWait({
                    // Удаляем старую статистику по этому параметру
                    let fetchRequest = NSFetchRequest(entityName: PlayerRank.entityName())
                    fetchRequest.predicate = NSPredicate(format: "parameter.objectId = %d", self.paramId)
                    do {
                        let all = try context.executeFetchRequest(fetchRequest) as! [PlayerRank]
                        for rank in all {
                            print("DELETE PlayerRank \(rank.player?.lastNameRu)")
                            context.deleteObject(rank)
                        }
                    }
                    catch {}
                    
                    for rankDict in ranksDicts {
                        if let _ = PlayerRank.rankWithDict(rankDict, paramId: self.paramId, inContext: context) {
                            self.responseCount += 1
                        }
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