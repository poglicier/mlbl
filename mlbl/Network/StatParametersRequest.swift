//
//  StatParametersRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 10.08.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class StatParametersRequest: NetworkRequest {
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        let urlString = "GetBestPlayerParameters"
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
            if let statParametersDicts = json as? [[String:AnyObject]] {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                context.parent = self.dataController?.mainContext
                context.perform({
                    var statParameterIdsToSave = [NSNumber]()
                    for statParameterDict in statParametersDicts {
                        let statParameter = StatParameter.parameterWithDict(statParameterDict, inContext: context)
                        
                        if let parameterId = statParameter?.objectId {
                            statParameterIdsToSave.append(parameterId)
                        }
                    }
                    
                    // Удаляем из Core Data параметры
                    let fetchRequest = NSFetchRequest<StatParameter>(entityName: StatParameter.entityName())
                    
                    do {
                        let all = try context.fetch(fetchRequest)
                        for parameter in all {
                            if let parameterId = parameter.objectId {
                                if statParameterIdsToSave.contains(parameterId) == false {
                                    print("DELETE StatParameter \(parameter.name ?? "")")
                                    context.delete(parameter)
                                }
                            }
                        }
                    }
                    catch {}
                    
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
