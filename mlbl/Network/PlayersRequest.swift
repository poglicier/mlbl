//
//  PlayersRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 18.07.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class PlayersRequest: NetworkRequest {
    private var compId: Int!
    var from: Int!
    var count: Int!
    var searchText: String?
    private(set) var emptyAnswer = false
    
    init(from: Int, count: Int, compId: Int, searchText: String? = nil) {
        super.init()
        
        self.from = from
        self.count = count
        self.compId = compId
        self.searchText = searchText
    }
    
    override func start() {
        if cancelled {
            finished = true
            return
        }
        
        var urlString = "CompGamePlayers/\(self.compId)?skip=\(self.from)&take=\(self.count)"
        if let search = self.searchText?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
            urlString += "&search=\(search)"
        }
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
            if let playerDicts = json as? [[String:AnyObject]] {
                if playerDicts.count == 0 {
                    self.emptyAnswer = true
                } else {
                    let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                    context.parentContext = self.dataController?.mainContext
                    context.performBlockAndWait({
                        var playerIdsToSave = [NSNumber]()
                        for playerDict in playerDicts {
                            let player = Player.playerWithDict(playerDict, inContext: context)
                            
                            if let playerId = player?.objectId {
                                playerIdsToSave.append(playerId)
                            }
                        }
                        
                        self.dataController?.saveContext(context)
                    })
                }
            } else {
                self.error = NSError(domain: "internal app error", code: -1, userInfo: [NSLocalizedDescriptionKey : "Обработка запроса не реализована"])
            }
        } catch {
            self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "Не смог разобрать json"])
        }
    }
}