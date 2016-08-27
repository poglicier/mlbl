//
//  PlayoffRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 26.08.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class PlayoffRequest: NetworkRequest {
    
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
        
        let urlString = "Playoff/\(self.compId)?format=json"
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
            } else if let playoffDicts = json as? [[String:AnyObject]] {
                let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                context.parentContext = self.dataController?.mainContext
                context.performBlockAndWait({
                    // Удаляем все плей-офф, потому что у них не идентификаторов
                    let fetchRequest = NSFetchRequest(entityName: PlayoffSerie.entityName())
                    fetchRequest.predicate = NSPredicate(format: "competition.objectId = %d", self.compId)
                    do {
                        let all = try context.executeFetchRequest(fetchRequest) as! [PlayoffSerie]
                        for rank in all {
                            print("DELETE PlayoffSerie \(rank.team1?.nameRu) - \(rank.team2?.nameRu)")
                            context.deleteObject(rank)
                        }
                    }
                    catch {}
                    
                    var series = [PlayoffSerie]()
                    for playoffDict in playoffDicts {
                        if let serie = PlayoffSerie.playoffWithDict(playoffDict, compId: self.compId, inContext: context) {
                            series.append(serie)
                        }
                    }
                    
                    // Теперь для отображения игр на вылет по секциям необходимо ввести параметр sectionSort
                    series.sortInPlace({ (serie1, serie2) -> Bool in
                        if serie1.round?.integerValue ?? -1 < serie2.round?.integerValue ?? -1 {
                            return true
                        } else if serie1.round == serie2.round {
                            return serie1.sort?.integerValue ?? -1 < serie2.sort?.integerValue ?? -1
                        } else {
                            return false
                        }
                    })
                    var lastSerie: PlayoffSerie?
                    for serie in series {
                        if serie.round?.integerValue ?? -1 != lastSerie?.round?.integerValue ?? -1 {
                            serie.sectionSort = NSNumber(integer: (lastSerie?.sectionSort?.integerValue ?? -1) + 1)
                        } else if serie.roundNameRu == lastSerie?.roundNameRu {
                            serie.sectionSort = lastSerie?.sectionSort
                        } else {
                            serie.sectionSort = NSNumber(integer: (lastSerie?.sectionSort?.integerValue ?? -1) + 1)
                        }
                        
                        lastSerie = serie
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