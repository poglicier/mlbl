//
//  TeamStatsRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 04.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class TeamStatsRequest: NetworkRequest {
    private var compId: Int!
    private var teamId: Int!
    
    init(compId: Int, teamId: Int) {
        super.init()
        
        self.compId = compId
        self.teamId = teamId
    }
    
    override func start() {
        if cancelled {
            finished = true
            return
        }
        
        let urlString = "TeamStats/\(self.teamId)?compId=\(self.compId)&format=json"
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
            if let teamStatsDict = json as? [String:AnyObject] {
                let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                context.parentContext = self.dataController?.mainContext
                context.performBlockAndWait({
                    // У статистики нет id, поэтому удалем все старые
                    let fetchRequest = NSFetchRequest(entityName: TeamStatistics.entityName())
                    fetchRequest.predicate = NSPredicate(format: "team.objectId = %d", self.teamId)
                    do {
                        let all = try context.executeFetchRequest(fetchRequest) as! [TeamStatistics]
                        for stat in all {
                            print("DELETE TeamStatistics \(stat.team?.nameRu)")
                            context.deleteObject(stat)
                        }
                    }
                    catch {}
                    
                    TeamStatistics.teamStatisticsWithDict(teamStatsDict, inContext: context)
                    self.dataController?.saveContext(context)
                })
            } else {
                self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "json не является словарём"])
            }
        } catch {
            self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "Не смог разобрать json"])
        }
    }
}