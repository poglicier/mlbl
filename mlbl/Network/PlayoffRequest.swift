//
//  PlayoffRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 26.08.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class PlayoffRequest: NetworkRequest {
    
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
        
        let urlString = "Playoff/\(self.compId!)?format=json"
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
            } else if let playoffDicts = json as? [[String:AnyObject]] {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                context.parent = self.dataController?.mainContext
                context.performAndWait({
                    // Удаляем все плей-офф, потому что у них нет идентификаторов
                    let fetchRequest = NSFetchRequest<PlayoffSerie>(entityName: PlayoffSerie.entityName())
                    fetchRequest.predicate = NSPredicate(format: "competition.objectId = %d", self.compId)
                    do {
                        let all = try context.fetch(fetchRequest)
                        for rank in all {
                            print("DELETE PlayoffSerie \(rank.team1?.nameRu) - \(rank.team2?.nameRu)")
                            context.delete(rank)
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
                    series.sort(by: { (serie1, serie2) -> Bool in
                        if serie1.round?.intValue ?? -1 < serie2.round?.intValue ?? -1 {
                            return true
                        } else if serie1.round == serie2.round {
                            return serie1.sort?.intValue ?? -1 < serie2.sort?.intValue ?? -1
                        } else {
                            return false
                        }
                    })
                    var lastSerie: PlayoffSerie?
                    for serie in series {
                        if serie.round?.intValue ?? -1 != lastSerie?.round?.intValue ?? -1 {
                            serie.sectionSort = NSNumber(value: (lastSerie?.sectionSort?.intValue ?? -1) + 1 as Int)
                        } else if serie.roundNameRu == lastSerie?.roundNameRu {
                            serie.sectionSort = lastSerie?.sectionSort
                        } else {
                            serie.sectionSort = NSNumber(value: (lastSerie?.sectionSort?.intValue ?? -1) + 1 as Int)
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
