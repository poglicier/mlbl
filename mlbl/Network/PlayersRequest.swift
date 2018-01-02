//
//  PlayersRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 18.07.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class PlayersRequest: NetworkRequest {
    fileprivate var compId: Int!
    var from: Int!
    var count: Int!
    var searchText: String?
    fileprivate(set) var responseCount = 0
    
    init(from: Int, count: Int, compId: Int, searchText: String? = nil) {
        super.init()
        
        self.from = from
        self.count = count
        self.compId = compId
        self.searchText = searchText
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        var urlString = "CompGamePlayers/\(self.compId!)?skip=\(self.from)&take=\(self.count)"
        if let search = self.searchText?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            urlString += "&search=\(search)"
        }
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
    
    func convertToDictionary(text: String?) -> Any? {
        if let data = text?.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    override func processData() {
        do {
            let json = try JSONSerialization.jsonObject(with: incomingData as Data, options: .allowFragments)
            if let playerDicts = convertToDictionary(text: (json as? String)) as? [[String:AnyObject]] {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                context.parent = self.dataController?.mainContext
                context.performAndWait({
                    for playerDict in playerDicts {
                        if let _ = Player.playerWithDict(playerDict, inContext: context) {
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
