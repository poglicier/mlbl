//
//  Team.swift
//  
//
//  Created by Valentin Shamardin on 05.03.16.
//
//

import Foundation
import CoreData

class Team: NSManagedObject {
    static let TeamIdKey = "TeamId"
    static let ShortTeamNameRuKey = "ShortTeamNameRu"
    static let ShortTeamNameEnKey = "ShortTeamNameEn"
    static let TeamNameRuKey = "TeamNameRu"
    static let TeamNameEnKey = "TeamNameEn"
    static private let CurrentTeamNameKey = "CurrentTeamName"
    static private let CurrentTeamIdKey = "TeamID"
    static private let CompTeamShortNameRuKey = "CompTeamShortNameRu"
    static private let CompTeamShortNameEnKey = "CompTeamShortNameEn"
    static private let CompTeamNameRuKey = "CompTeamNameRu"
    static private let CompTeamNameEnKey = "CompTeamNameEn"
    static private let CompTeamRegionNameRuKey = "CompTeamRegionNameRu"
    static private let CompTeamRegionNameEnKey = "CompTeamRegionNameEn"
    
    static func teamWithDict(dict: [String:AnyObject], inContext context: NSManagedObjectContext) -> Team? {
        var res: Team?
        
        if let objectId = dict[TeamIdKey] as? NSNumber {
            let fetchRequest = NSFetchRequest(entityName: Team.entityName())
            fetchRequest.predicate = NSPredicate(format: "objectId = %@", objectId)
            do {
                res = try context.executeFetchRequest(fetchRequest).first as? Team
                
                if res == nil {
                    res = Team.init(entity: NSEntityDescription.entityForName(Team.entityName(), inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
                    res?.objectId = objectId
                }
            } catch { }
        }
        
        res?.shortNameEn = dict[ShortTeamNameEnKey] as? String
        res?.shortNameRu = dict[ShortTeamNameRuKey] as? String
        res?.nameEn = dict[TeamNameEnKey] as? String
        res?.nameRu = dict[TeamNameRuKey] as? String
        
        return res
    }
    
    static func teamStatsWithDict(dict: [String:AnyObject], inContext context: NSManagedObjectContext) -> Team? {
        var res: Team?
        
        if let objectId = dict[TeamIdKey] as? NSNumber {
            let fetchRequest = NSFetchRequest(entityName: Team.entityName())
            fetchRequest.predicate = NSPredicate(format: "objectId = %@", objectId)
            do {
                res = try context.executeFetchRequest(fetchRequest).first as? Team
                
                if res == nil {
                    res = Team.init(entity: NSEntityDescription.entityForName(Team.entityName(), inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
                    res?.objectId = objectId
                }
            } catch { }
        }
        
        return res
    }
    
    static func teamWithInfoDict(dict: [String: AnyObject], inContext context: NSManagedObjectContext) -> Team? {
        var res: Team?
        
        if var currentTeamDict = dict[CurrentTeamNameKey] as? [String:AnyObject] {
            var teamDict = [String:AnyObject]()
            teamDict[TeamIdKey] = currentTeamDict[CurrentTeamIdKey] as? Int
            teamDict[ShortTeamNameRuKey] = currentTeamDict[CompTeamShortNameRuKey] as? String
            teamDict[ShortTeamNameEnKey] = currentTeamDict[CompTeamShortNameEnKey] as? String
            teamDict[TeamNameRuKey] = currentTeamDict[CompTeamNameRuKey] as? String
            teamDict[TeamNameEnKey] = currentTeamDict[CompTeamNameEnKey] as? String
            
            res = teamWithDict(teamDict, inContext: context)
            res?.regionNameEn = currentTeamDict[CompTeamRegionNameEnKey] as? String
            res?.regionNameRu = currentTeamDict[CompTeamRegionNameRuKey] as? String
        }
        
        return res
    }
}