//
//  GamesRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 07.07.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class GamesRequest: NetworkRequest {
    fileprivate var date: Date!
    fileprivate var compId: Int!
    fileprivate(set) var prevDate: Date?
    fileprivate(set) var nextDate: Date?
    
    init(date: Date, compId: Int) {
        super.init()
        
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year, .month, .day], from:date)
        self.date = calendar.date(from: components)
        self.compId = compId
    }
    
    static fileprivate var dateFormatter: DateFormatter = {
        let res = DateFormatter()
        res.dateFormat = "dd.MM.yyyy"
        return res
    } ()
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YYYY"
        
        guard let url = URL(string: "CalendarDay/\(self.compId!)?from=\(GamesRequest.dateFormatter.string(from: self.date))", relativeTo: self.baseUrl as URL?) else { fatalError("Failed to build URL") }
        
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
            if let dict = json as? [String:AnyObject] {
                if let prevDateString = dict["PrevDate"] as? String {
                    self.prevDate = GamesRequest.dateFormatter.date(from: prevDateString)
                }
                if let nextDateString = dict["NextDate"] as? String {
                    self.nextDate = GamesRequest.dateFormatter.date(from: nextDateString)
                }
                
                if let gamesDicts = dict["Games"] as? [[String:AnyObject]] {
                    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                    context.parent = self.dataController?.mainContext
                    context.performAndWait({
                        var gameIdsToSave = [NSNumber]()
                        for gameDict in gamesDicts {
                            let game = Game.gameWithDict(gameDict, in: context)
                            
                            if let gameId = game?.objectId {
                                gameIdsToSave.append(gameId)
                            }
                        }
                        
                        // Удаляем из Core Data игры
                        let fetchRequest = NSFetchRequest<Game>(entityName: Game.entityName())
                        fetchRequest.predicate = NSPredicate(format: "date = %@", self.date as CVarArg)
                        
                        do {
                            let all = try context.fetch(fetchRequest)
                            for game in all {
                                if let gameId = game.objectId {
                                    if gameIdsToSave.contains(gameId) == false {
                                        var dateStr = ""
                                        
                                        if let _ = game.date {
                                            dateStr = "\(game.date!)"
                                        }
                                        print("DELETE Game \(dateStr)")
                                        context.delete(game)
                                    }
                                }
                            }
                        }
                        catch {}
                        
                        self.dataController?.saveContext(context)
                    })
                } else {
                    self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "Поле Games отсутствует"])
                }
            }
        } catch {
            self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "Не смог разобрать json"])
        }
    }
}
