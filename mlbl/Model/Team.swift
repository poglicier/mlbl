//
//  Team.swift
//  
//
//  Created by Valentin Shamardin on 05.03.16.
//
//

import Foundation
import CoreData

public class Team: NSManagedObject {
    static let TeamIdKey = "TeamId"
    static let ShortTeamNameRuKey = "ShortTeamNameRu"
    static let ShortTeamNameEnKey = "ShortTeamNameEn"
    static let TeamNameRuKey = "TeamNameRu"
    static let TeamNameEnKey = "TeamNameEn"
    static fileprivate let CurrentTeamNameKey = "CurrentTeamName"
    static fileprivate let CurrentTeamIdKey = "TeamID"
    static fileprivate let CompTeamShortNameRuKey = "CompTeamShortNameRu"
    static fileprivate let CompTeamShortNameEnKey = "CompTeamShortNameEn"
    static fileprivate let CompTeamNameRuKey = "CompTeamNameRu"
    static fileprivate let CompTeamNameEnKey = "CompTeamNameEn"
    static fileprivate let CompTeamRegionNameRuKey = "CompTeamRegionNameRu"
    static fileprivate let CompTeamRegionNameEnKey = "CompTeamRegionNameEn"
    
    @discardableResult
    static func teamWithDict(_ dict: [String:AnyObject], inContext context: NSManagedObjectContext) -> Team? {
        var res: Team?
        
        if let objectId = dict[TeamIdKey] as? NSNumber {
            let fetchRequest = NSFetchRequest<Team>(entityName: Team.entityName())
            fetchRequest.predicate = NSPredicate(format: "objectId = %@", objectId)
            do {
                res = try context.fetch(fetchRequest).first
                
                if res == nil {
                    res = Team.init(entity: NSEntityDescription.entity(forEntityName: Team.entityName(), in: context)!, insertInto: context)
                    res?.objectId = objectId
                }
            } catch { }
        }
        
        if let shortNameEn = dict[ShortTeamNameEnKey] as? String {
            res?.shortNameEn = shortNameEn
        }
        if let shortNameRu = dict[ShortTeamNameRuKey] as? String {
            res?.shortNameRu = shortNameRu
        }
        if let nameEn = dict[TeamNameEnKey] as? String {
             res?.nameEn = nameEn
        }
        if let nameRu = dict[TeamNameRuKey] as? String {
            res?.nameRu = nameRu
        }
        
        return res
    }
    
    @discardableResult
    static func teamStatsWithDict(_ dict: [String:AnyObject], inContext context: NSManagedObjectContext) -> Team? {
        var res: Team?
        
        if let objectId = dict[TeamIdKey] as? NSNumber {
            let fetchRequest = NSFetchRequest<Team>(entityName: Team.entityName())
            fetchRequest.predicate = NSPredicate(format: "objectId = %@", objectId)
            do {
                res = try context.fetch(fetchRequest).first
                
                if res == nil {
                    res = Team.init(entity: NSEntityDescription.entity(forEntityName: Team.entityName(), in: context)!, insertInto: context)
                    res?.objectId = objectId
                }
            } catch { }
        }
        
        return res
    }
    
    @discardableResult
    static func teamWithInfoDict(_ dict: [String: AnyObject], inContext context: NSManagedObjectContext) -> Team? {
        var res: Team?
        
        if var currentTeamDict = dict[CurrentTeamNameKey] as? [String:AnyObject] {
            var teamDict = [String:AnyObject]()
            teamDict[TeamIdKey] = currentTeamDict[CurrentTeamIdKey] as? Int as AnyObject?
            teamDict[ShortTeamNameRuKey] = currentTeamDict[CompTeamShortNameRuKey] as? String as AnyObject?
            teamDict[ShortTeamNameEnKey] = currentTeamDict[CompTeamShortNameEnKey] as? String as AnyObject?
            teamDict[TeamNameRuKey] = currentTeamDict[CompTeamNameRuKey] as? String as AnyObject?
            teamDict[TeamNameEnKey] = currentTeamDict[CompTeamNameEnKey] as? String as AnyObject?
            
            res = teamWithDict(teamDict, inContext: context)
            res?.regionNameEn = currentTeamDict[CompTeamRegionNameEnKey] as? String
            res?.regionNameRu = currentTeamDict[CompTeamRegionNameRuKey] as? String
        }
        
        return res
    }
    
    static func updateSubscriptionInfo(forTeamWithId teamId: Int, subscribed: Bool, in context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<Team>(entityName: Team.entityName())
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Team.objectId)) = \(teamId)")
        do {
            let team = try context.fetch(fetchRequest).first
            team?.subscribed = NSNumber(value: subscribed)
        } catch { }
    }
}
