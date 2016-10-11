//
//  PlayerStatistics+CoreDataClass.swift
//  
//
//  Created by Valentin Shamardin on 10.10.16.
//
//

import Foundation
import CoreData

public class PlayerStatistics: NSManagedObject {
    
    static fileprivate let TeamIdKey = "TeamID"
    static fileprivate let TeamNameAKey = "TeamNameA"
    static fileprivate let TeamNameBKey = "TeamNameB"
    static fileprivate let GameDateKey = "GameDate"
    static fileprivate let CompTeamShortNameRuKey = "CompTeamShortNameRu"
    static fileprivate let CompShortTeamNameEnKey = "CompShortTeamNameEn"
    static fileprivate let CompTeamNameRuKey = "CompTeamNameRu"
    static fileprivate let CompTeamNameEnKey = "CompTeamNameEn"
    static fileprivate let PointsKey = "Points"
    static fileprivate let Shot1Key = "Shot1"
    static fileprivate let Shot2Key = "Shot2"
    static fileprivate let Shot3Key = "Shot3"
    static fileprivate let Goal1Key = "Goal1"
    static fileprivate let Goal2Key = "Goal2"
    static fileprivate let Goal3Key = "Goal3"
    static fileprivate let AssistsKey = "Assist"
    static fileprivate let DefReboundsKey = "DefRebound"
    static fileprivate let OffReboundsKey = "OffRebound"
    static fileprivate let StealsKey = "Steal"
    static fileprivate let TurnoversKey = "Turnover"
    static fileprivate let SecondsKey = "Seconds"
    static fileprivate let PlusMinusKey = "PlusMinus"
    static fileprivate let BlocksKey = "Blocks"
    static fileprivate let TeamNumberKey = "TeamNumber"
    static fileprivate let LastNameRuKey = "LastNameRu"
    static fileprivate let LastNameEnKey = "LastNameEn"
    static fileprivate let FirstNameRuKey = "FirstNameRu"
    static fileprivate let FirstNameEnKey = "FirstNameEn"
    static fileprivate let PersonBirthKey = "PersonBirth"
    static fileprivate let HeightKey = "Height"
    static fileprivate let WeightKey = "Weight"
    static fileprivate let FoulsKey = "Foul"
    static fileprivate let OpponentFoulsKey = "OpponentFoul"
    static fileprivate let GameStatsKey = "GameStats"
    static fileprivate let GameKey = "Game"
    static fileprivate let AvgShots1Key = "AvgShots1"
    static fileprivate let AvgShots2Key = "AvgShots2"
    static fileprivate let AvgShots3Key = "AvgShots3"
    static fileprivate let AvgPointsKey = "AvgPoints"
    static fileprivate let AvgAssistKey = "AvgAssist"
    static fileprivate let AvgBlocksKey = "AvgBlocks"
    static fileprivate let AvgDefReboundKey = "AvgDefRebound"
    static fileprivate let AvgOffReboundKey = "AvgOffRebound"
    static fileprivate let AvgReboundKey = "AvgRebound"
    static fileprivate let AvgStealKey = "AvgSteal"
    static fileprivate let AvgTurnoverKey = "AvgTurnover"
    static fileprivate let AvgFoulKey = "AvgFoul"
    static fileprivate let AvgOpponentFoulKey = "AvgOpponentFoul"
    static fileprivate let AvgPlusMinusKey = "AvgPlusMinus"
    static fileprivate let AvgPlayedTimeKey = "AvgPlayedTime"
    
    // MARK: - Private
    static fileprivate var numberFormatter: NumberFormatter! = {
        let res = NumberFormatter()
        res.numberStyle = .decimal
        return res
    }()
    
    /// Статистика игрока в игре
    @discardableResult
    static fileprivate func playerStatisticsWithDict(_ dict: [String:AnyObject], playerId: Int, in game: Game?, in context: NSManagedObjectContext) -> PlayerStatistics? {
        var res: PlayerStatistics?
        let fetchRequest = NSFetchRequest<Player>(entityName: Player.entityName())
        fetchRequest.predicate = NSPredicate(format: "objectId = %d", playerId)
        do {
            if let player = try context.fetch(fetchRequest).first {
                res = PlayerStatistics(entity: NSEntityDescription.entity(forEntityName: PlayerStatistics.entityName(), in: context)!, insertInto: context)
                res?.player = player
            }
        } catch {}
        
        if let _ = game {
            res?.game = game
            res?.fouls = dict[FoulsKey] as? NSNumber
            res?.opponentFouls = dict[OpponentFoulsKey] as? NSNumber
            res?.points = dict[PointsKey] as? NSNumber ?? 0
            res?.shot1 = dict[Shot1Key] as? NSNumber ?? 0
            res?.shot2 = dict[Shot2Key] as? NSNumber ?? 0
            res?.shot3 = dict[Shot3Key] as? NSNumber ?? 0
            res?.goal1 = dict[Goal1Key] as? NSNumber ?? 0
            res?.goal2 = dict[Goal2Key] as? NSNumber ?? 0
            res?.goal3 = dict[Goal3Key] as? NSNumber ?? 0
            res?.assists = dict[AssistsKey] as? NSNumber ?? 0
            res?.steals = dict[StealsKey] as? NSNumber ?? 0
            res?.offensiveRebounds = dict[OffReboundsKey] as? NSNumber ?? 0
            res?.defensiveRebounds = dict[DefReboundsKey] as? NSNumber ?? 0
            res?.turnovers = dict[TurnoversKey] as? NSNumber ?? 0
            res?.blocks = dict[BlocksKey] as? NSNumber ?? 0
            res?.plusMinus = dict[PlusMinusKey] as? NSNumber ?? 0
            res?.seconds = dict[SecondsKey] as? NSNumber ?? 0
        } else {
            if let str = dict[AvgFoulKey] as? String {
                res?.fouls = self.numberFormatter.number(from: str)
            }
            if let str = dict[AvgOpponentFoulKey] as? String {
                res?.opponentFouls = self.numberFormatter.number(from: str)
            }
            if let str = dict[AvgPointsKey] as? String {
                res?.points = self.numberFormatter.number(from: str)
            }
            if let str = dict[AvgShots1Key] as? String {
                let parts = str.components(separatedBy: "/")
                if parts.count == 2 {
                    res?.goal1 = self.numberFormatter.number(from: parts[0])
                    res?.shot1 = self.numberFormatter.number(from: parts[1])
                }
            }
            if let str = dict[AvgShots2Key] as? String {
                let parts = str.components(separatedBy: "/")
                if parts.count == 2 {
                    res?.goal2 = self.numberFormatter.number(from: parts[0])
                    res?.shot2 = self.numberFormatter.number(from: parts[1])
                }
            }
            if let str = dict[AvgShots3Key] as? String {
                let parts = str.components(separatedBy: "/")
                if parts.count == 2 {
                    res?.goal3 = self.numberFormatter.number(from: parts[0])
                    res?.shot3 = self.numberFormatter.number(from: parts[1])
                }
            }
            if let str = dict[AvgAssistKey] as? String {
                res?.assists = self.numberFormatter.number(from: str)
            }
            if let str = dict[AvgStealKey] as? String {
                res?.steals = self.numberFormatter.number(from: str)
            }
            if let str = dict[AvgOffReboundKey] as? String {
                res?.offensiveRebounds = self.numberFormatter.number(from: str)
            }
            if let str = dict[AvgDefReboundKey] as? String {
                res?.defensiveRebounds = self.numberFormatter.number(from: str)
            }
            if let str = dict[AvgTurnoverKey] as? String {
                res?.turnovers = self.numberFormatter.number(from: str)
            }
            if let str = dict[AvgBlocksKey] as? String {
                res?.blocks = self.numberFormatter.number(from: str)
            }
            if let str = dict[AvgPlusMinusKey] as? String {
                res?.plusMinus = self.numberFormatter.number(from: str)
            }
            if let str = dict[AvgPlayedTimeKey] as? String {
                let parts = str.components(separatedBy: ":")
                if parts.count == 2 {
                    var seconds = (self.numberFormatter.number(from: parts[0])?.intValue ?? 0)*60
                    seconds += self.numberFormatter.number(from: parts[1])?.intValue ?? 0
                    res?.seconds = NSNumber(value: seconds)
                }
            }
        }
        
        return res
    }
    
    // MARK: - Public

    static func playerStatisticsWithDict(_ dict: [String:AnyObject], playerId: Int, in context: NSManagedObjectContext) {
        
        if let gameStatDicts = dict[GameStatsKey] as? [[String:AnyObject]] {
            // Статистика по играм
            for gameStatDict in gameStatDicts {
                if let gameDict = gameStatDict[GameKey] as? [String:AnyObject] {
                    var fixedGameDict = gameDict
                    fixedGameDict[Game.GameDateKey] = gameStatDict[GameDateKey]
                    if let game = Game.gameWithDict(fixedGameDict, inContext: context) {
                        let res = self.playerStatisticsWithDict(gameStatDict, playerId: playerId, in: game, in: context)
                        if let teamADict = gameStatDict[TeamNameAKey] as? [String:AnyObject] {
                            var teamDict = [String:AnyObject]()
                            teamDict[Team.TeamIdKey] = teamADict[TeamIdKey]
                            teamDict[Team.ShortTeamNameRuKey] = teamADict[CompTeamShortNameRuKey]
                            teamDict[Team.ShortTeamNameEnKey] = teamADict[CompShortTeamNameEnKey]
                            teamDict[Team.TeamNameRuKey] = teamADict[CompTeamNameRuKey]
                            teamDict[Team.TeamNameEnKey] = teamADict[CompTeamNameRuKey]
                            res?.teamA = Team.teamWithDict(teamDict, inContext: context)
                        }
                        
                        if let teamBDict = gameStatDict[TeamNameBKey] as? [String:AnyObject] {
                            var teamDict = [String:AnyObject]()
                            teamDict[Team.TeamIdKey] = teamBDict[TeamIdKey]
                            teamDict[Team.ShortTeamNameRuKey] = teamBDict[CompTeamShortNameRuKey]
                            teamDict[Team.ShortTeamNameEnKey] = teamBDict[CompShortTeamNameEnKey]
                            teamDict[Team.TeamNameRuKey] = teamBDict[CompTeamNameRuKey]
                            teamDict[Team.TeamNameEnKey] = teamBDict[CompTeamNameRuKey]
                            res?.teamB = Team.teamWithDict(teamDict, inContext: context)
                        }
                    }
                }
            }
        }
        
        self.playerStatisticsWithDict(dict, playerId: playerId, in: nil, in: context)
    }
}
