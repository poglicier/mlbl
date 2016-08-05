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
    static private let ScoreAKey = "ScoreA"
    static private let ScoreBKey = "ScoreB"
    static private let GameNumberKey = "GameNumber"
    static private let VenueRuKey = "VenueRu"
    static private let VenueEnKey = "VenueEn"
    static private let ScoreByPeriodsKey = "ScoreByPeriods"
    static private let TeamAKey = "TeamA"
    static private let TeamBKey = "TeamB"
    static private let ShortTeamNameAruKey = "ShortTeamNameAru"
    static private let ShortTeamNameBruKey = "ShortTeamNameBru"
    static private let TeamNameAruKey = "TeamNameAru"
    static private let TeamNameBruKey = "TeamNameBru"
    static private let ShortTeamNameAenKey = "ShortTeamNameAen"
    static private let ShortTeamNameBenKey = "ShortTeamNameBen"
    static private let TeamNameAenKey = "TeamNameAen"
    static private let TeamNameBenKey = "TeamNameBen"
    static private let TeamAIdKey = "TeamAid"
    static private let TeamBIdKey = "TeamBid"
    static private let PlayersKey = "Players"
    static private let CoachKey = "Coach"
    
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
                    res = Game(entity: NSEntityDescription.entityForName(Game.entityName(), inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
                    res?.objectId = objectId
                }
                
                if let dateString = dict[GameDateKey] as? String {
                    if let timeString = dict[GameTimeKey] as? String {
                        res?.date = self.dateFormatter.dateFromString("\(dateString) \(timeString)")
                    }
                }
                
                if let scoreA = dict[ScoreAKey] as? Int {
                    res?.scoreA = scoreA
                }
                if let scoreB = dict[ScoreBKey] as? Int {
                    res?.scoreB = scoreB
                }

                if let statisticsADict = dict[TeamAKey] as? [String:AnyObject] {
                    if let statisticsA = GameStatistics.gameStatisticsWithDict(statisticsADict, gameId: objectId as Int, inContext: context) {
                        res?.addStatisticsObject(statisticsA)
                        
                        if let playersDicts = statisticsADict[PlayersKey] as? [[String:AnyObject]] {
                            for playerDict in playersDicts {
                                if let playerStat = GameStatistics.gameStatisticsWithDict(playerDict, gameId: objectId as Int, inContext: context) {
                                    res?.addStatisticsObject(playerStat)
                                }
                            }
                        }
                        
                        if let coachDict = statisticsADict[CoachKey] as? [String:AnyObject] {
                            if let coachStat = GameStatistics.gameStatisticsWithDict(coachDict, gameId: objectId as Int, inContext: context) {
                                res?.addStatisticsObject(coachStat)
                            }
                        }
                    }
                }
                
                if let statisticsBDict = dict[TeamBKey] as? [String:AnyObject] {
                    if let statisticsB = GameStatistics.gameStatisticsWithDict(statisticsBDict, gameId: objectId as Int, inContext: context) {
                        res?.addStatisticsObject(statisticsB)
                        
                        if let playersDicts = statisticsBDict[PlayersKey] as? [[String:AnyObject]] {
                            for playerDict in playersDicts {
                                if let playerStat = GameStatistics.gameStatisticsWithDict(playerDict, gameId: objectId as Int, inContext: context) {
                                    res?.addStatisticsObject(playerStat)
                                }
                            }
                        }
                        
                        if let coachDict = statisticsBDict[CoachKey] as? [String:AnyObject] {
                            if let coachStat = GameStatistics.gameStatisticsWithDict(coachDict, gameId: objectId as Int, inContext: context) {
                                res?.addStatisticsObject(coachStat)
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
                    res?.teamAId = teamAId
                }
                if let teamBId = dict[TeamBIdKey] as? Int {
                    res?.teamBId = teamBId
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
            } catch {}
        }
        
        return res
    }
    
    func addStatisticsObject(value: GameStatistics) {
        var newItems: Set<GameStatistics>
        if let statistics = self.statistics {
            newItems = statistics as! Set<GameStatistics>
        } else {
            newItems = Set<GameStatistics>()
        }
        newItems.insert(value)
        self.statistics = newItems
    }
    
    func removeStatisticsObject(value: GameStatistics) {
        var newItems: Set<GameStatistics>
        if let statistics = self.statistics {
            newItems = statistics as! Set<GameStatistics>
        } else {
            newItems = Set<GameStatistics>()
        }
        newItems.remove(value)
        self.statistics = newItems
    }
}