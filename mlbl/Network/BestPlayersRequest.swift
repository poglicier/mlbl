//
//  BestPlayersRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 17.08.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class BestPlayersRequest: NetworkRequest {
    fileprivate var compId: Int!
    fileprivate var paramId: Int!
    fileprivate(set) var responseCount = 0
    
    init(paramId: Int, compId: Int, searchText: String? = nil) {
        super.init()
        
        self.compId = compId
        self.paramId = paramId
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        let urlString = "BestPlayers/\(self.compId!)?param=\(self.paramId!)&format=json"
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
            if let ranksDicts = json as? [[String:AnyObject]] {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                context.parent = self.dataController?.mainContext
                context.performAndWait({
                    // Удаляем старую статистику по этому параметру
                    let fetchRequest = NSFetchRequest<PlayerRank>(entityName: PlayerRank.entityName())
                    fetchRequest.predicate = NSPredicate(format: "parameter.objectId = %d", self.paramId)
                    do {
                        let all = try context.fetch(fetchRequest)
                        for rank in all {
                            print("DELETE PlayerRank \(rank.player?.lastNameRu ?? "")")
                            context.delete(rank)
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
