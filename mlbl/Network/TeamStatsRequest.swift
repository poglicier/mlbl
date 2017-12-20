//
//  TeamStatsRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 04.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class TeamStatsRequest: NetworkRequest {
    fileprivate var compId: Int!
    fileprivate var teamId: Int!
    
    init(compId: Int, teamId: Int) {
        super.init()
        
        self.compId = compId
        self.teamId = teamId
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        let urlString = "TeamStats/\(self.teamId!)?compId=\(self.compId!)&format=json"
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
            if let teamStatsDict = json as? [String:AnyObject] {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                context.parent = self.dataController?.mainContext
                context.performAndWait({
                    // У статистики нет id, поэтому удалем все старые
                    let fetchRequest = NSFetchRequest<TeamStatistics>(entityName: TeamStatistics.entityName())
                    fetchRequest.predicate = NSPredicate(format: "team.objectId = %d", self.teamId)
                    do {
                        let all = try context.fetch(fetchRequest)
                        for stat in all {
                            print("DELETE TeamStatistics \(stat.team?.nameRu ?? "")")
                            context.delete(stat)
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
