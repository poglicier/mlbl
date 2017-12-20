//
//  CompetitionsRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 20.07.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class CompetitionsRequest: NetworkRequest {
    fileprivate var parentId: Int?
    
    init(parentId: Int?) {
        super.init()
        
        self.parentId = parentId
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        var optionalUrl: URL?
        if let _ = parentId {
            optionalUrl = URL(string: "CompIssue/\(self.parentId!)", relativeTo: self.baseUrl)
        } else {
            optionalUrl = URL(string: "http://ilovebasket.ru/comps2.json", relativeTo: nil)
        }
        guard let url = optionalUrl else { fatalError("Failed to build URL") }

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
            if let result = json as? [String:AnyObject] {
                if let comps = result["Comps"] as? [[String:AnyObject]] {
                    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                    context.parent = self.dataController?.mainContext
                    context.performAndWait() {
                        // Удаляем из Core Data все регионы
                        let fetchRequest = NSFetchRequest<Competition>(entityName: Competition.entityName())
                        if let _ = self.parentId {
                            fetchRequest.predicate = NSPredicate(format: "objectId != %d", self.parentId!)
                        }
                        
                        do {
                            let all = try context.fetch(fetchRequest)
                            for comp in all {
                                print("DELETE COMPETITION \(comp.compAbcNameRu ?? "")-\(comp.compShortNameRu ?? "")")
                                context.delete(comp)
                            }
                        }
                        catch {}
                        
                        var parentComp: Competition?
                        if let _ = self.parentId {
                            fetchRequest.predicate = NSPredicate(format: "objectId = %d", self.parentId!)
                            do {
                                parentComp = try context.fetch(fetchRequest).first
                            } catch {}
                        }
                        
                        for compDict in comps {
                            let comp = Competition.compWithDict(compDict, inContext: context)
                            comp?.parent = parentComp
                        }
                        
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
