//
//  CompetitionsRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 20.07.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class CompetitionsRequest: NetworkRequest {
    private var parentId: Int!
    
    init(parentId: Int) {
        super.init()
        
        self.parentId = parentId
    }
    
    override func start() {
        if cancelled {
            finished = true
            return
        }
        
        guard let url = NSURL(string: "CompIssue/\(self.parentId)", relativeToURL: self.baseUrl) else { fatalError("Failed to build URL") }
        
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
            if let result = json as? [String:AnyObject] {
                if let comps = result["Comps"] as? [[String:AnyObject]] {
                    let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                    context.parentContext = self.dataController?.mainContext
                    context.performBlockAndWait() {
                        var compIdsToSave = [NSNumber]()
                        for compDict in comps {
                            let comp = Competition.compWithDict(compDict, inContext: context)
                            
                            if let compId = comp?.objectId {
                                compIdsToSave.append(compId)
                            }
                        }
                        
                        // Удаляем из Core Data регионы
                        let fetchRequest = NSFetchRequest(entityName: Competition.entityName())
                        fetchRequest.predicate = NSPredicate(format: "parent = nil")
                        
                        do {
                            let all = try context.executeFetchRequest(fetchRequest) as! [Competition]
                            for comp in all {
                                if let compId = comp.objectId {
                                    if compIdsToSave.contains(compId) == false {
                                        print("DELETE COMPETITION \(comp.compAbcNameRu)-\(comp.compShortNameRu)")
                                        context.deleteObject(comp)
                                    }
                                }
                            }
                        }
                        catch {}
                        
                        self.dataController?.saveContext(context)
                    }
                } else {
                    self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "Comps не массив"])
                }
            } else {
                self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "json не словарь"])
            }
        } catch {
            self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "Не смог разобрать json"])
        }
    }
}