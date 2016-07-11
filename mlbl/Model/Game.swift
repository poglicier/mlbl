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
    //        private let GameNumberKey = "GameNumber"
    //        private let VenueRuKey = "VenueRu"
    //        private let VenueEnKey = "VenueEn"
    //        private let ScoreByPeriodsKey = "ScoreByPeriods"
    //        private let TeamAKey = "TeamA"
    //        private let TeamBKey = "TeamB"
    
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
//                res?.venueEn = dict[Keys.VenueEn.rawValue] as? String
//                res?.venueRu = dict[Keys.VenueRu.rawValue] as? String
//                res?.scoreByPeriods = dict[Keys.ScoreByPeriods.rawValue] as? String
//                
//                if let teamA = dict[Keys.TeamA.rawValue] as? [String:AnyObject] {
//                    res?.scoreA = teamA[Keys.Score.rawValue] as? NSNumber
//                }
//                
//                if let teamB = dict[Keys.TeamB.rawValue] as? [String:AnyObject] {
//                    res?.scoreB = teamB[Keys.Score.rawValue] as? NSNumber
//                }
            } catch {}
        }
        
        return res
    }
}