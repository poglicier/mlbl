//
//  Game.swift
//  
//
//  Created by Valentin Shamardin on 05.03.16.
//
//

import Foundation
import CoreData

public class Game: NSManagedObject {
    
    enum GameStatus: Int {
        case scheduled
        case accomplished
        case online
        case dateChanged
        case cancelled
    }
    
    static fileprivate let GameIdKey = "GameID"
    static let GameDateKey = "GameDate"
    static fileprivate let GameTimeKey = "GameTime"
    static let ScoreAKey = "ScoreA"
    static let ScoreBKey = "ScoreB"
    static fileprivate let GameNumberKey = "GameNumber"
    static fileprivate let VenueRuKey = "VenueRu"
    static fileprivate let VenueEnKey = "VenueEn"
    static fileprivate let ScoreByPeriodsKey = "ScoreByPeriods"
    static fileprivate let TeamAKey = "TeamA"
    static fileprivate let TeamBKey = "TeamB"
    static let ShortTeamNameAruKey = "ShortTeamNameAru"
    static let ShortTeamNameBruKey = "ShortTeamNameBru"
    static let TeamNameAruKey = "TeamNameAru"
    static let TeamNameBruKey = "TeamNameBru"
    static let ShortTeamNameAenKey = "ShortTeamNameAen"
    static let ShortTeamNameBenKey = "ShortTeamNameBen"
    static let TeamNameAenKey = "TeamNameAen"
    static let TeamNameBenKey = "TeamNameBen"
    static let TeamAIdKey = "TeamAid"
    static let TeamBIdKey = "TeamBid"
    static fileprivate let PlayersKey = "Players"
    static fileprivate let CoachKey = "Coach"
    static fileprivate let GameStatusKey = "GameStatus"
    
    static fileprivate var dateFormatter: DateFormatter = {
        let res = DateFormatter()
        res.dateFormat = "dd.MM.yyyy HH.mm"
        return res
    }()
    
    @discardableResult
    static func gameWithDict(_ dict: [String:AnyObject], inContext context: NSManagedObjectContext) -> Game? {
        var res: Game?
        
        if let objectId = dict[GameIdKey] as? NSNumber {
            let fetchRequest = NSFetchRequest<Game>(entityName: Game.entityName())
            fetchRequest.predicate = NSPredicate(format: "objectId = %@", objectId)
            do {
                res = try context.fetch(fetchRequest).first
                
                if res == nil {
                    res = Game(entity: NSEntityDescription.entity(forEntityName: Game.entityName(), in: context)!, insertInto: context)
                    res?.objectId = objectId
                }
                
                if let dateString = dict[GameDateKey] as? String {
                    if let timeString = dict[GameTimeKey] as? String {
                        res?.date = self.dateFormatter.date(from: "\(dateString) \(timeString)") as NSDate?
                        if res?.date == nil {
                            res?.date = self.dateFormatter.date(from: dateString + " 0:0") as NSDate?
                        }
                    }
                }
                
                if let scoreA = dict[ScoreAKey] as? Int {
                    res?.scoreA = scoreA as NSNumber?
                }
                if let scoreB = dict[ScoreBKey] as? Int {
                    res?.scoreB = scoreB as NSNumber?
                }

                if let statisticsADict = dict[TeamAKey] as? [String:AnyObject] {
                    if let statisticsA = GameStatistics.gameStatisticsWithDict(statisticsADict, gameId: objectId as Int, inContext: context) {
                        res?.addToStatistics(statisticsA)
                        
                        if let playersDicts = statisticsADict[PlayersKey] as? [[String:AnyObject]] {
                            for playerDict in playersDicts {
                                if let playerStat = GameStatistics.gameStatisticsWithDict(playerDict, gameId: objectId as Int, inContext: context) {
                                    res?.addToStatistics(playerStat)
                                }
                            }
                        }
                        
                        if let coachDict = statisticsADict[CoachKey] as? [String:AnyObject] {
                            if let coachStat = GameStatistics.gameStatisticsWithDict(coachDict, gameId: objectId as Int, inContext: context) {
                                res?.addToStatistics(coachStat)
                            }
                        }
                    }
                }
                
                if let statisticsBDict = dict[TeamBKey] as? [String:AnyObject] {
                    if let statisticsB = GameStatistics.gameStatisticsWithDict(statisticsBDict, gameId: objectId as Int, inContext: context) {
                        res?.addToStatistics(statisticsB)
                        
                        if let playersDicts = statisticsBDict[PlayersKey] as? [[String:AnyObject]] {
                            for playerDict in playersDicts {
                                if let playerStat = GameStatistics.gameStatisticsWithDict(playerDict, gameId: objectId as Int, inContext: context) {
                                    res?.addToStatistics(playerStat)
                                }
                            }
                        }
                        
                        if let coachDict = statisticsBDict[CoachKey] as? [String:AnyObject] {
                            if let coachStat = GameStatistics.gameStatisticsWithDict(coachDict, gameId: objectId as Int, inContext: context) {
                                res?.addToStatistics(coachStat)
                            }
                        }
                    }
                }
                
                if let nameARu = dict[TeamNameAruKey] as? String {
                    res?.teamNameAru = nameARu
                }
                if let nameAEn = dict[TeamNameAenKey] as? String {
                    res?.teamNameAen = nameAEn
                }
                if let shortNameARu = dict[ShortTeamNameAruKey] as? String {
                    res?.shortTeamNameAru = shortNameARu
                }
                if let shortNameAEn = dict[ShortTeamNameAenKey] as? String {
                    res?.shortTeamNameAen = shortNameAEn
                }
                if let nameBRu = dict[TeamNameBruKey] as? String {
                    res?.teamNameBru = nameBRu
                }
                if let nameBEn = dict[TeamNameBenKey] as? String {
                    res?.teamNameBen = nameBEn
                }
                if let shortNameBRu = dict[ShortTeamNameBruKey] as? String {
                    res?.shortTeamNameBru = shortNameBRu
                }
                if let shortNameBEn = dict[ShortTeamNameBenKey] as? String {
                    res?.shortTeamNameBen = shortNameBEn
                }
                if let teamAId = dict[TeamAIdKey] as? Int {
                    res?.teamAId = teamAId as NSNumber?
                }
                if let teamBId = dict[TeamBIdKey] as? Int {
                    res?.teamBId = teamBId as NSNumber?
                }
                if let venueEn = dict[VenueEnKey] as? String {
                    res?.venueEn = venueEn
                }
                if let venueRu = dict[VenueRuKey] as? String {
                    res?.venueRu = venueRu
                }
                if let scoreByPeriods = dict[ScoreByPeriodsKey] as? String {
                    res?.scoreByPeriods = scoreByPeriods
                }
                if let status = dict[GameStatusKey] as? Int {
                    res?.status = status as NSNumber?
                }
            } catch {}
        }
        
        return res
    }
}
