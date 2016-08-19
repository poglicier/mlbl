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
        if cancelled {
            finished = true
            return
        }
        
        let urlString = "GetBestPlayerParameters"
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
            if let statParametersDicts = json as? [[String:AnyObject]] {
                let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                context.parentContext = self.dataController?.mainContext
                context.performBlock({
                    var statParameterIdsToSave = [NSNumber]()
                    for statParameterDict in statParametersDicts {
                        let statParameter = StatParameter.parameterWithDict(statParameterDict, inContext: context)
                        
                        if let parameterId = statParameter?.objectId {
                            statParameterIdsToSave.append(parameterId)
                        }
                    }
                    
                    // Удаляем из Core Data параметры
                    let fetchRequest = NSFetchRequest(entityName: StatParameter.entityName())
                    
                    do {
                        let all = try context.executeFetchRequest(fetchRequest) as! [StatParameter]
                        for parameter in all {
                            if let parameterId = parameter.objectId {
                                if statParameterIdsToSave.contains(parameterId) == false {
                                    print("DELETE StatParameter \(parameter.name)")
                                    context.deleteObject(parameter)
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