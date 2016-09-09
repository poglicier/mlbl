//
//  TeamStatistics.swift
//  
//
//  Created by Valentin Shamardin on 04.09.16.
//
//

import Foundation
import CoreData


class TeamStatistics: NSManagedObject {

    static private let TeamIdKey = "TeamID"
    static private let PlayersKey = "Players"
    static private let PersonIdKey = "PersonID"
    static private let PointsKey = "Points"
    static private let Shot1Key = "Shot1"
    static private let Shot2Key = "Shot2"
    static private let Shot3Key = "Shot3"
    static private let Goal1Key = "Goal1"
    static private let Goal2Key = "Goal2"
    static private let Goal3Key = "Goal3"
    static private let AssistsKey = "Assist"
    static private let DefReboundsKey = "DefRebound"
    static private let OffReboundsKey = "OffRebound"
    static private let StealsKey = "Steal"
    static private let TurnoversKey = "Turnover"
    static private let SecondsKey = "Seconds"
    static private let PlusMinusKey = "PlusMinus"
    static private let BlocksKey = "Blocks"
    static private let TeamNumberKey = "TeamNumber"
    static private let PlayerNumberKey = "PlayerNumber"
    static private let LastNameRuKey = "LastNameRu"
    static private let LastNameEnKey = "LastNameEn"
    static private let FirstNameRuKey = "FirstNameRu"
    static private let FirstNameEnKey = "FirstNameEn"
    static private let PersonBirthKey = "PersonBirth"
    static private let HeightKey = "Height"
    static private let WeightKey = "Weight"
    static private let IsStartKey = "IsStart"
    static private let FoulsKey = "Foul"
    static private let OpponentFoulsKey = "OpponentFoul"
    static private let AvgShots1Key = "AvgShots1"
    static private let AvgShots2Key = "AvgShots2"
    static private let AvgShots3Key = "AvgShots3"
    static private let AvgPointsKey = "AvgPoints"
    static private let AvgAssistKey = "AvgAssist"
    static private let AvgBlocksKey = "AvgBlocks"
    static private let AvgDefReboundKey = "AvgDefRebound"
    static private let AvgOffReboundKey = "AvgOffRebound"
    static private let AvgReboundKey = "AvgRebound"
    static private let AvgStealKey = "AvgSteal"
    static private let AvgTurnoverKey = "AvgTurnover"
    static private let AvgFoulKey = "AvgFoul"
    static private let AvgOpponentFoulKey = "AvgOpponentFoul"
    static private let AvgPlusMinusKey = "AvgPlusMinus"
    static private let AvgTeamDefReboundKey = "AvgTeamDefRebound"
    static private let AvgTeamOffReboundKey = "AvgTeamOffRebound"
    static private let AvgTeamReboundKey = "AvgTeamRebound"
    static private let AvgTeamStealKey = "AvgTeamSteal"
    static private let AvgTeamTurnoverKey = "AvgTeamTurnover"
    static private let AvgPlayedTimeKey = "AvgPlayedTime"
    
    static func teamStatisticsWithDict(dict: [String:AnyObject], inContext context: NSManagedObjectContext) -> TeamStatistics? {
        var res: TeamStatistics?
        
        // Статистика команды
        if let teamId = dict[TeamIdKey] as? NSNumber {
            let fetchRequest = NSFetchRequest(entityName: TeamStatistics.entityName())
            fetchRequest.predicate = NSPredicate(format: "team.objectId = %@ AND player == nil", teamId)
            do {
                res = try context.executeFetchRequest(fetchRequest).first as? TeamStatistics
                
                if res == nil {
                    let fetchRequest = NSFetchRequest(entityName: Team.entityName())
                    fetchRequest.predicate = NSPredicate(format: "objectId = %@", teamId)
                    do {
                        if let team = try context.executeFetchRequest(fetchRequest).first as? Team {
                            // Создаём TeamStatistics только когда у него будет команда
                            res = TeamStatistics(entity: NSEntityDescription.entityForName(TeamStatistics.entityName(), inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
                            res?.team = team
                        }
                    } catch {}
                }
            } catch {}
            
            if let playerStatsDicts = dict[PlayersKey] as? [[String:AnyObject]] {
                for playerStatDict in playerStatsDicts {
                    // Статистика игрока
                    if let playerStat = TeamStatistics.teamStatisticsWithDict(playerStatDict, inContext:context) {
                        playerStat.team = res?.team
                    }
                }
            }
            
            if let floatStr = dict[AvgFoulKey] as? String {
                res?.fouls = self.numberFormatter.numberFromString(floatStr)
            }
            if let floatStr = dict[AvgOpponentFoulKey] as? String {
                res?.opponentFouls = self.numberFormatter.numberFromString(floatStr)
            }
            if let floatStr = dict[AvgPointsKey] as? String {
                res?.points = self.numberFormatter.numberFromString(floatStr)
            }
            
            if let shots = dict[AvgShots1Key] as? String {
                let comps = shots.componentsSeparatedByString("/")
                if comps.count == 2 {
                    res?.goal1 = self.numberFormatter.numberFromString(comps[0])
                    res?.shot1 = self.numberFormatter.numberFromString(comps[1])
                }
            }
            if let shots = dict[AvgShots2Key] as? String {
                let comps = shots.componentsSeparatedByString("/")
                if comps.count == 2 {
                    res?.goal2 = self.numberFormatter.numberFromString(comps[0])
                    res?.shot2 = self.numberFormatter.numberFromString(comps[1])
                }
            }
            if let shots = dict[AvgShots3Key] as? String {
                let comps = shots.componentsSeparatedByString("/")
                if comps.count == 2 {
                    res?.goal3 = self.numberFormatter.numberFromString(comps[0])
                    res?.shot3 = self.numberFormatter.numberFromString(comps[1])
                }
            }
            
            if let floatStr = dict[AvgAssistKey] as? String {
                res?.assists = self.numberFormatter.numberFromString(floatStr)
            }
            if let floatStr = dict[AvgStealKey] as? String {
                res?.steals = self.numberFormatter.numberFromString(floatStr)
            }
            if let floatStr = dict[AvgOffReboundKey] as? String {
                res?.offensiveRebounds = self.numberFormatter.numberFromString(floatStr)
            }
            if let floatStr = dict[AvgDefReboundKey] as? String {
                res?.defensiveRebounds = self.numberFormatter.numberFromString(floatStr)
            }
            if let floatStr = dict[AvgTeamOffReboundKey] as? String {
                res?.teamOffensiveRebounds = self.numberFormatter.numberFromString(floatStr)
            }
            if let floatStr = dict[AvgTeamDefReboundKey] as? String {
                res?.teamDefensiveRebounds = self.numberFormatter.numberFromString(floatStr)
            }
            if let floatStr = dict[AvgTurnoverKey] as? String {
                res?.turnovers = self.numberFormatter.numberFromString(floatStr)
            }
            if let floatStr = dict[AvgBlocksKey] as? String {
                res?.blocks = self.numberFormatter.numberFromString(floatStr)
            }
            if let floatStr = dict[AvgPlusMinusKey] as? String {
                res?.plusMinus = self.numberFormatter.numberFromString(floatStr)
            }
            if let timeStr = dict[AvgPlayedTimeKey] as? String {
                let comps = timeStr.componentsSeparatedByString(":")
                if comps.count == 2 {
                    res?.seconds = comps[0].integer()*60 + comps[1].integer()
                }
            }
            
            // Чтобы в fetchedResultsController статистика команды была в самом конце
            res?.playerNumber = 9999
        } else {
            // Статистика игрока
            if let personId = dict[PersonIdKey] as? Int {
                let fetchRequest = NSFetchRequest(entityName: TeamStatistics.entityName())
                fetchRequest.predicate = NSPredicate(format: "player.objectId = %d", personId)
                do {
                    res = try context.executeFetchRequest(fetchRequest).first as? TeamStatistics
                    
                    if res == nil {
                        let fetchRequest = NSFetchRequest(entityName: Player.entityName())
                        fetchRequest.predicate = NSPredicate(format: "objectId = %d", personId)
                        do {
                            if let player = try context.executeFetchRequest(fetchRequest).first as? Player {
                                // Создаём TeamStatistics только когда у него будет игрок
                                res = TeamStatistics(entity: NSEntityDescription.entityForName(TeamStatistics.entityName(), inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
                                res?.player = player
                            }
                        } catch {}
                    }
                } catch {}
            }
            
            res?.playerNumber = dict[PlayerNumberKey] as? Int
            
            res?.teamNumber = dict[TeamNumberKey] as? Int
            res?.fouls = dict[FoulsKey] as? Int
            res?.opponentFouls = dict[OpponentFoulsKey] as? Int
            res?.points = dict[PointsKey] as? Int ?? 0
            res?.shot1 = dict[Shot1Key] as? Int ?? 0
            res?.shot2 = dict[Shot2Key] as? Int ?? 0
            res?.shot3 = dict[Shot3Key] as? Int ?? 0
            res?.goal1 = dict[Goal1Key] as? Int ?? 0
            res?.goal2 = dict[Goal2Key] as? Int ?? 0
            res?.goal3 = dict[Goal3Key] as? Int ?? 0
            res?.assists = dict[AssistsKey] as? Int ?? 0
            res?.steals = dict[StealsKey] as? Int ?? 0
            res?.offensiveRebounds = dict[OffReboundsKey] as? Int ?? 0
            res?.defensiveRebounds = dict[DefReboundsKey] as? Int ?? 0
            res?.turnovers = dict[TurnoversKey] as? Int ?? 0
            res?.blocks = dict[BlocksKey] as? Int ?? 0
            res?.plusMinus = dict[PlusMinusKey] as? Int ?? 0
            res?.seconds = dict[SecondsKey] as? Int ?? 0
        }
        
        return res
    }
    
    // MARK: - Private
    
    private static let numberFormatter: NSNumberFormatter! = {
        let formatter = NSNumberFormatter()
        formatter.decimalSeparator = ","
        return formatter
    } ()
}