//
//  GamesRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 07.07.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class GamesRequest: NetworkRequest {
    private var date: NSDate!
    private var compId: Int!
    private(set) var prevDate: NSDate?
    private(set) var nextDate: NSDate?
    
    init(date: NSDate, compId: Int) {
        super.init()
        
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate:date)
        self.date = calendar.dateFromComponents(components)
        self.compId = compId
    }
    
    static private var dateFormatter: NSDateFormatter = {
        let res = NSDateFormatter()
        res.dateFormat = "dd.MM.yyyy"
        return res
    } ()
    
    override func start() {
        if cancelled {
            finished = true
            return
        }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd.MM.YYYY"
        
        guard let url = NSURL(string: "CalendarDay/\(self.compId)?from=\(GamesRequest.dateFormatter.stringFromDate(self.date))", relativeToURL: self.baseUrl) else { fatalError("Failed to build URL") }
        
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
            if let dict = json as? [String:AnyObject] {
                if let prevDateString = dict["PrevDate"] as? String {
                    self.prevDate = GamesRequest.dateFormatter.dateFromString(prevDateString)
                }
                if let nextDateString = dict["NextDate"] as? String {
                    self.nextDate = GamesRequest.dateFormatter.dateFromString(nextDateString)
                }
                
                if let gamesDicts = dict["Games"] as? [[String:AnyObject]] {
                    let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                    context.parentContext = self.dataController?.mainContext
                    context.performBlock({
                        var gameIdsToSave = [NSNumber]()
                        for gameDict in gamesDicts {
                            let game = Game.gameWithDict(gameDict, inContext: context)
                            
                            if let gameId = game?.objectId {
                                gameIdsToSave.append(gameId)
                            }
                        }
                        
                        // Удаляем из Core Data игры
                        let fetchRequest = NSFetchRequest(entityName: Game.entityName())
                        fetchRequest.predicate = NSPredicate(format: "date = %@", self.date)
                        
                        do {
                            let all = try context.executeFetchRequest(fetchRequest) as! [Game]
                            for game in all {
                                if let gameId = game.objectId {
                                    if gameIdsToSave.contains(gameId) == false {
                                        print("DELETE Game \(game.objectId)")
                                        context.deleteObject(game)
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