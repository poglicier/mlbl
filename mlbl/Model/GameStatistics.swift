//
//  GameStatistics.swift
//  
//
//  Created by Valentin Shamardin on 27.07.16.
//
//

import Foundation
import CoreData

class GameStatistics: NSManagedObject {
    
    static fileprivate let TeamIdKey = "TeamID"
    static fileprivate let TeamNameKey = "TeamName"
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
    static fileprivate let TeamDefReboundKey = "TeamDefRebound"
    static fileprivate let TeamOffReboundKey = "TeamOffRebound"
    
    @discardableResult
    static func gameStatisticsWithDict(_ dict: [String:AnyObject], gameId: Int, inContext context: NSManagedObjectContext) -> GameStatistics? {
        var res: GameStatistics?
        
        // Статистика команды
        if let teamId = dict[TeamIdKey] as? NSNumber {
            let fetchRequest = NSFetchRequest<GameStatistics>(entityName: GameStatistics.entityName())
            fetchRequest.predicate = NSPredicate(format: "game.objectId = \(gameId) AND team.objectId = %@", teamId)
            do {
                res = try context.fetch(fetchRequest).first
                
                if res == nil {
                    res = GameStatistics(entity: NSEntityDescription.entity(forEntityName: GameStatistics.entityName(), in: context)!, insertInto: context)
                    
                    if let teamGameDict = dict[TeamNameKey] as? [String:AnyObject] {
                        var teamDict = [String:AnyObject]()
                        teamDict[Team.TeamIdKey] = teamGameDict[TeamIdKey] as? Int as AnyObject?
                        teamDict[Team.ShortTeamNameRuKey] = teamGameDict[CompTeamShortNameRuKey] as? String as AnyObject?
                        teamDict[Team.ShortTeamNameEnKey] = teamGameDict[CompShortTeamNameEnKey] as? String as AnyObject?
                        teamDict[Team.TeamNameRuKey] = teamGameDict[CompTeamNameRuKey] as? String as AnyObject?
                        teamDict[Team.TeamNameEnKey] = teamGameDict[CompTeamNameEnKey] as? String as AnyObject?
                        res?.team = Team.teamWithDict(teamDict, inContext: context)
                    }
                }
            } catch {}
            
            // Чтобы в fetchedResultsController статистика команды была в самом конце
            res?.playerNumber = 9999
        } else if let personId = dict[Player.PlayerIdKey] as? NSNumber {
            // Статистика игрока
            let fetchRequest = NSFetchRequest<GameStatistics>(entityName: GameStatistics.entityName())
            fetchRequest.predicate = NSPredicate(format: "game.objectId = \(gameId) AND player.objectId = %@", personId)
            do {
                res = try context.fetch(fetchRequest).first
                
                if res == nil {
                    res = GameStatistics(entity: NSEntityDescription.entity(forEntityName: GameStatistics.entityName(), in: context)!, insertInto: context)
                    
                    var playerDict = [String:AnyObject]()
                    playerDict[Player.PlayerIdKey] = personId
                    var personInfo = [String:AnyObject]()
                    personInfo[Player.PersonLastNameRuKey] = dict[LastNameRuKey] as? String as AnyObject?
                    personInfo[Player.PersonLastNameEnKey] = dict[LastNameEnKey] as? String as AnyObject?
                    personInfo[Player.PersonFirstNameRuKey] = dict[FirstNameRuKey] as? String as AnyObject?
                    personInfo[Player.PersonFirstNameEnKey] = dict[FirstNameEnKey] as? String as AnyObject?
                    personInfo[Player.PersonBirthdayKey] = dict[PersonBirthKey] as? String as AnyObject?
                    personInfo[Player.PersonHeightKey] = dict[HeightKey] as? Int as AnyObject?
                    personInfo[Player.PersonWeightKey] = dict[WeightKey] as? Int as AnyObject?
                    playerDict[Player.PersonInfoKey] = personInfo as AnyObject?
                    res?.player = Player.playerWithDict(playerDict, inContext: context)
                }
            } catch {}
            
            res?.playerNumber = dict[PlayerNumberKey] as? Int as NSNumber?
        }
        
        res?.teamNumber = dict[TeamNumberKey] as? Int as NSNumber?
        res?.fouls = dict[FoulsKey] as? Int as NSNumber?
        res?.opponentFouls = dict[OpponentFoulsKey] as? Int as NSNumber?
        res?.isStart = dict[IsStartKey] as? Bool as NSNumber?
        res?.points = dict[PointsKey] as? Int as NSNumber?? ?? 0
        res?.shot1 = dict[Shot1Key] as? Int as NSNumber?? ?? 0
        res?.shot2 = dict[Shot2Key] as? Int as NSNumber?? ?? 0
        res?.shot3 = dict[Shot3Key] as? Int as NSNumber?? ?? 0
        res?.goal1 = dict[Goal1Key] as? Int as NSNumber?? ?? 0
        res?.goal2 = dict[Goal2Key] as? Int as NSNumber?? ?? 0
        res?.goal3 = dict[Goal3Key] as? Int as NSNumber?? ?? 0
        res?.assists = dict[AssistsKey] as? Int as NSNumber?? ?? 0
        res?.steals = dict[StealsKey] as? Int as NSNumber?? ?? 0
        res?.offensiveRebounds = dict[OffReboundsKey] as? Int as NSNumber?? ?? 0
        res?.defensiveRebounds = dict[DefReboundsKey] as? Int as NSNumber?? ?? 0
        res?.teamOffensiveRebounds = dict[TeamOffReboundKey] as? Int as NSNumber?? ?? 0
        res?.teamDefensiveRebounds = dict[TeamDefReboundKey] as? Int as NSNumber?? ?? 0
        res?.turnovers = dict[TurnoversKey] as? Int as NSNumber?? ?? 0
        res?.blocks = dict[BlocksKey] as? Int as NSNumber?? ?? 0
        res?.plusMinus = dict[PlusMinusKey] as? Int as NSNumber?? ?? 0
        res?.seconds = dict[SecondsKey] as? Int as NSNumber?? ?? 0
        
        return res
    }
}
