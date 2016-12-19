//
//  OnlineStatusRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 19.12.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class OnlineStatusRequest: NetworkRequest {

    fileprivate var gameIds: [Int]!
    
    init(gameIds: [Int]) {
        super.init()
        
        self.gameIds = gameIds
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        let ids = self.gameIds.map { "\($0)" }.joined(separator: ",")
        let urlString = "GetOnlineStatus/?games=\(ids)"
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
            if let gameStatusDicts = json as? [[String:AnyObject]] {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                context.parent = self.dataController?.mainContext
                context.performAndWait({
                    for gameStatusDict in gameStatusDicts {
                        Game.updateWithStatusDict(gameStatusDict, in: context)
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
