//
//  TeamStatistics.swift
//  
//
//  Created by Valentin Shamardin on 04.09.16.
//
//

import Foundation
import CoreData


public class TeamStatistics: NSManagedObject {

    static fileprivate let TeamIdKey = "TeamID"
    static fileprivate let PlayersKey = "Players"
    static fileprivate let PersonIdKey = "PersonID"
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
    static fileprivate let PlayerNumberKey = "PlayerNumber"
    static fileprivate let LastNameRuKey = "LastNameRu"
    static fileprivate let LastNameEnKey = "LastNameEn"
    static fileprivate let FirstNameRuKey = "FirstNameRu"
    static fileprivate let FirstNameEnKey = "FirstNameEn"
    static fileprivate let PersonBirthKey = "PersonBirth"
    static fileprivate let HeightKey = "Height"
    static fileprivate let WeightKey = "Weight"
    static fileprivate let IsStartKey = "IsStart"
    static fileprivate let FoulsKey = "Foul"
    static fileprivate let OpponentFoulsKey = "OpponentFoul"
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
    static fileprivate let AvgTeamDefReboundKey = "AvgTeamDefRebound"
    static fileprivate let AvgTeamOffReboundKey = "AvgTeamOffRebound"
    static fileprivate let AvgTeamReboundKey = "AvgTeamRebound"
    static fileprivate let AvgTeamStealKey = "AvgTeamSteal"
    static fileprivate let AvgTeamTurnoverKey = "AvgTeamTurnover"
    static fileprivate let AvgPlayedTimeKey = "AvgPlayedTime"
    
    @discardableResult
    static func teamStatisticsWithDict(_ dict: [String:AnyObject], inContext context: NSManagedObjectContext) -> TeamStatistics? {
        var res: TeamStatistics?
        
        // Статистика команды
        if let teamId = dict[TeamIdKey] as? NSNumber {
            let fetchRequest = NSFetchRequest<TeamStatistics>(entityName: TeamStatistics.entityName())
            fetchRequest.predicate = NSPredicate(format: "team.objectId = %@ AND player == nil", teamId)
            do {
                res = try context.fetch(fetchRequest).first
                
                if res == nil {
                    let fetchRequest = NSFetchRequest<Team>(entityName: Team.entityName())
                    fetchRequest.predicate = NSPredicate(format: "objectId = %@", teamId)
                    do {
                        if let team = try context.fetch(fetchRequest).first {
                            // Создаём TeamStatistics только когда у него будет команда
                            res = TeamStatistics(entity: NSEntityDescription.entity(forEntityName: TeamStatistics.entityName(), in: context)!, insertInto: context)
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
                res?.fouls = self.numberFormatter.number(from: floatStr)
            }
            if let floatStr = dict[AvgOpponentFoulKey] as? String {
                res?.opponentFouls = self.numberFormatter.number(from: floatStr)
            }
            if let floatStr = dict[AvgPointsKey] as? String {
                res?.points = self.numberFormatter.number(from: floatStr)
            }
            
            if let shots = dict[AvgShots1Key] as? String {
                let comps = shots.components(separatedBy: "/")
                if comps.count == 2 {
                    res?.goal1 = self.numberFormatter.number(from: comps[0])
                    res?.shot1 = self.numberFormatter.number(from: comps[1])
                }
            }
            if let shots = dict[AvgShots2Key] as? String {
                let comps = shots.components(separatedBy: "/")
                if comps.count == 2 {
                    res?.goal2 = self.numberFormatter.number(from: comps[0])
                    res?.shot2 = self.numberFormatter.number(from: comps[1])
                }
            }
            if let shots = dict[AvgShots3Key] as? String {
                let comps = shots.components(separatedBy: "/")
                if comps.count == 2 {
                    res?.goal3 = self.numberFormatter.number(from: comps[0])
                    res?.shot3 = self.numberFormatter.number(from: comps[1])
                }
            }
            
            if let floatStr = dict[AvgAssistKey] as? String {
                res?.assists = self.numberFormatter.number(from: floatStr)
            }
            if let floatStr = dict[AvgStealKey] as? String {
                res?.steals = self.numberFormatter.number(from: floatStr)
            }
            if let floatStr = dict[AvgOffReboundKey] as? String {
                res?.offensiveRebounds = self.numberFormatter.number(from: floatStr)
            }
            if let floatStr = dict[AvgDefReboundKey] as? String {
                res?.defensiveRebounds = self.numberFormatter.number(from: floatStr)
            }
            if let floatStr = dict[AvgTeamOffReboundKey] as? String {
                res?.teamOffensiveRebounds = self.numberFormatter.number(from: floatStr)
            }
            if let floatStr = dict[AvgTeamDefReboundKey] as? String {
                res?.teamDefensiveRebounds = self.numberFormatter.number(from: floatStr)
            }
            if let floatStr = dict[AvgTurnoverKey] as? String {
                res?.turnovers = self.numberFormatter.number(from: floatStr)
            }
            if let floatStr = dict[AvgBlocksKey] as? String {
                res?.blocks = self.numberFormatter.number(from: floatStr)
            }
            if let floatStr = dict[AvgPlusMinusKey] as? String {
                res?.plusMinus = self.numberFormatter.number(from: floatStr)
            }
            if let timeStr = dict[AvgPlayedTimeKey] as? String {
                let comps = timeStr.components(separatedBy: ":")
                if comps.count == 2 {
                    res?.seconds = NSNumber(value: comps[0].integer()*60 + comps[1].integer())
                }
            }
            
            // Чтобы в fetchedResultsController статистика команды была в самом конце
            res?.playerNumber = 9999
        } else {
            // Статистика игрока
            if let personId = dict[PersonIdKey] as? Int {
                let fetchRequest = NSFetchRequest<TeamStatistics>(entityName: TeamStatistics.entityName())
                fetchRequest.predicate = NSPredicate(format: "player.objectId = %d", personId)
                do {
                    res = try context.fetch(fetchRequest).first
                    
                    if res == nil {
                        let fetchRequest = NSFetchRequest<Player>(entityName: Player.entityName())
                        fetchRequest.predicate = NSPredicate(format: "objectId = %d", personId)
                        do {
                            if let player = try context.fetch(fetchRequest).first {
                                // Создаём TeamStatistics только когда у него будет игрок
                                res = TeamStatistics(entity: NSEntityDescription.entity(forEntityName: TeamStatistics.entityName(), in: context)!, insertInto: context)
                                res?.player = player
                            }
                        } catch {}
                    }
                } catch {}
            }
            
            res?.playerNumber = dict[PlayerNumberKey] as? Int as NSNumber?
            
            res?.teamNumber = dict[TeamNumberKey] as? Int as NSNumber?
            res?.fouls = dict[FoulsKey] as? Int as NSNumber?
            res?.opponentFouls = dict[OpponentFoulsKey] as? Int as NSNumber?
            res?.points = dict[PointsKey]as? NSNumber ?? 0
            res?.shot1 = dict[Shot1Key]as? NSNumber ?? 0
            res?.shot2 = dict[Shot2Key]as? NSNumber ?? 0
            res?.shot3 = dict[Shot3Key]as? NSNumber ?? 0
            res?.goal1 = dict[Goal1Key]as? NSNumber ?? 0
            res?.goal2 = dict[Goal2Key]as? NSNumber ?? 0
            res?.goal3 = dict[Goal3Key]as? NSNumber ?? 0
            res?.assists = dict[AssistsKey]as? NSNumber ?? 0
            res?.steals = dict[StealsKey]as? NSNumber ?? 0
            res?.offensiveRebounds = dict[OffReboundsKey]as? NSNumber ?? 0
            res?.defensiveRebounds = dict[DefReboundsKey]as? NSNumber ?? 0
            res?.turnovers = dict[TurnoversKey]as? NSNumber ?? 0
            res?.blocks = dict[BlocksKey]as? NSNumber ?? 0
            res?.plusMinus = dict[PlusMinusKey]as? NSNumber ?? 0
            res?.seconds = dict[SecondsKey]as? NSNumber ?? 0
        }
        
        return res
    }
    
    // MARK: - Private
    
    fileprivate static let numberFormatter: NumberFormatter! = {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = ","
        return formatter
    } ()
}
