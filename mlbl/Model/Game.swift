//
//  Game.swift
//  
//
//  Created by Valentin Shamardin on 05.03.16.
//
//

import Foundation
import CoreData

class Game: NSManagedObject {
    
    static private let GameIdKey = "GameID"
    static private let GameDateKey = "GameDate"
    static private let GameTimeKey = "GameTime"
    static private let TeamAIdKey = "TeamAid"
    static private let TeamBIdKey = "TeamBid"
    static private let ShortTeamNameAruKey = "ShortTeamNameAru"
    static private let ShortTeamNameBruKey = "ShortTeamNameBru"
    static private let ShortTeamNameAenKey = "ShortTeamNameAen"
    static private let ShortTeamNameBenKey = "ShortTeamNameBen"
    static private let TeamNameAruKey = "TeamNameAru"
    static private let TeamNameBruKey = "TeamNameBru"
    static private let TeamNameAenKey = "TeamNameAen"
    static private let TeamNameBenKey = "TeamNameBen"
    static private let ScoreAKey = "ScoreA"
    static private let ScoreBKey = "ScoreB"
    static private let GameNumberKey = "GameNumber"
    static private let VenueRuKey = "VenueRu"
    static private let VenueEnKey = "VenueEn"
    static private let ScoreByPeriodsKey = "ScoreByPeriods"
    static private let TeamAKey = "TeamA"
    static private let TeamBKey = "TeamB"
    
    static private var dateFormatter: NSDateFormatter = {
        let res = NSDateFormatter()
        res.dateFormat = "dd.MM.yyyy HH.mm"
        return res
    }()
    
    static func gameWithDict(dict: [String:AnyObject], inContext context: NSManagedObjectContext) -> Game? {
        var res: Game?
        
        if let objectId = dict[GameIdKey] as? NSNumber {
            let fetchRequest = NSFetchRequest(entityName: Game.entityName())
            fetchRequest.predicate = NSPredicate(format: "objectId = %@", objectId)
            do {
                res = try context.executeFetchRequest(fetchRequest).first as? Game
                
                if res == nil {
                    res = Game.init(entity: NSEntityDescription.entityForName(Game.entityName(), inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
                    res?.objectId = objectId
                }
                
                if let dateString = dict[GameDateKey] as? String {
                    if let timeString = dict[GameTimeKey] as? String {
                        res?.date = self.dateFormatter.dateFromString("\(dateString) \(timeString)")
                    }
                }
                
                res?.scoreA = dict[ScoreAKey] as? Int
                res?.scoreB = dict[ScoreBKey] as? Int

                var teamADict = [String:AnyObject]()
                teamADict[Team.TeamIdKey] = dict[TeamAIdKey]
                teamADict[Team.TeamNameEnKey] = dict[TeamNameAenKey]
                teamADict[Team.TeamNameRuKey] = dict[TeamNameAruKey]
                teamADict[Team.ShortTeamNameEnKey] = dict[ShortTeamNameAenKey]
                teamADict[Team.ShortTeamNameRuKey] = dict[ShortTeamNameAruKey]
                
                res?.teamA = Team.teamWithDict(teamADict, inContext: context)
                
                var teamBDict = [String:AnyObject]()
                teamBDict[Team.TeamIdKey] = dict[TeamBIdKey]
                teamBDict[Team.TeamNameEnKey] = dict[TeamNameBenKey]
                teamBDict[Team.TeamNameRuKey] = dict[TeamNameBruKey]
                teamBDict[Team.ShortTeamNameEnKey] = dict[ShortTeamNameBenKey]
                teamBDict[Team.ShortTeamNameRuKey] = dict[ShortTeamNameBruKey]
                
                res?.teamB = Team.teamWithDict(teamBDict, inContext: context)
            } catch {}
        }
        
        return res
    }
    
    static func gameWithStatDict(dict: [String:AnyObject], inContext context: NSManagedObjectContext) -> Game? {
        var res: Game?
        
        if let objectId = dict[GameIdKey] as? NSNumber {
            let fetchRequest = NSFetchRequest(entityName: Game.entityName())
            fetchRequest.predicate = NSPredicate(format: "objectId = %@", objectId)
            do {
                res = try context.executeFetchRequest(fetchRequest).first as? Game
                
                if res == nil {
                    res = Game.init(entity: NSEntityDescription.entityForName(Game.entityName(), inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
                    res?.objectId = objectId
                }
                
                if let dateString = dict[GameDateKey] as? String {
                    if let timeString = dict[GameTimeKey] as? String {
                        res?.date = self.dateFormatter.dateFromString("\(dateString) \(timeString)")
                    }
                }
                
//                if let teamADict = dict[TeamAKey] as? [String:AnyObject] {
//                    res?.teamA = Team.teamStatsWithDict(teamADict, inContext: context)
//                }
//                
//                if let teamBDict = dict[TeamBKey] as? [String:AnyObject] {
//                    res?.teamB = Team.teamStatsWithDict(teamBDict, inContext: context)
//                }
//                
//                res?.venueEn = dict[VenueEnKey] as? String
//                res?.venueRu = dict[VenueRuKey] as? String
//                res?.scoreByPeriods = dict[ScoreByPeriodsKey] as? String
            } catch {}
        }
        
        return res
    }
}