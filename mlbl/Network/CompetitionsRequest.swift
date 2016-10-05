//
//  CompetitionsRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 20.07.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class CompetitionsRequest: NetworkRequest {
    fileprivate var parentId: Int!
    
    init(parentId: Int) {
        super.init()
        
        self.parentId = parentId
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        guard let url = URL(string: "http://ilovebasket.ru/comps.json"/*"CompIssue/\(self.parentId!)"*/, relativeTo: nil/*self.baseUrl as URL?*/) else { fatalError("Failed to build URL") }
        
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
//            let url = Bundle.main.url(forResource: "comps.json", withExtension: nil)!
//            let data = try! Data(contentsOf: url)
//            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            let json = try JSONSerialization.jsonObject(with: incomingData as Data, options: .allowFragments)
            if let result = json as? [String:AnyObject] {
                if let comps = result["Comps"] as? [[String:AnyObject]] {
                    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                    context.parent = self.dataController?.mainContext
                    context.performAndWait() {
                        // Удаляем из Core Data все регионы
                        let fetchRequest = NSFetchRequest<Competition>(entityName: Competition.entityName())
                        
                        do {
                            let all = try context.fetch(fetchRequest)
                            for comp in all {
                                print("DELETE COMPETITION \(comp.compAbcNameRu)-\(comp.compShortNameRu)")
                                context.delete(comp)
                            }
                        }
                        catch {}
                        
                        for compDict in comps {
                            Competition.compWithDict(compDict, inContext: context)
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
