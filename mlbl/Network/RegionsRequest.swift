//
//  RegionsRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 07.07.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class RegionsRequest: NetworkRequest {
    override func start() {
        if cancelled {
            finished = true
            return
        }
        
        guard let url = NSURL(string: "GetRegions?format=json&country=1", relativeToURL: self.baseUrl) else { fatalError("Failed to build URL") }
        
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
            if let resultArray = json as? [[String:AnyObject]] {
                let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                context.parentContext = self.dataController?.mainContext
                context.performBlockAndWait() {
                    var regionIdsToSave = [NSNumber]()
                    for regionDict in resultArray {
                        let region = Region.regionWithDict(regionDict, inContext: context)
                        
                        if let regionId = region?.objectId {
                            regionIdsToSave.append(regionId)
                        }
                    }
                    
                    // Удаляем из Core Data регионы
                    let fetchRequest = NSFetchRequest(entityName: Region.entityName())
                    
                    do {
                        let all = try context.executeFetchRequest(fetchRequest) as! [Region]
                        for region in all {
                            if let regionId = region.objectId {
                                if regionIdsToSave.contains(regionId) == false {
                                    print("DELETE REGION \(region.nameRu)")
                                    context.deleteObject(region)
                                }
                            }
                        }
                    }
                    catch {}
                    
                    self.dataController?.saveContext(context)
                }
            } else {
                self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "json не массив"])
            }
        } catch {
            self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "Не смог разобрать json"])
        }
    }
}