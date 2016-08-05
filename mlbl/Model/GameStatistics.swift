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
    
    static private let TeamIdKey = "TeamID"
    static private let TeamNameKey = "TeamName"
    static private let CompTeamShortNameRuKey = "CompTeamShortNameRu"
    static private let CompShortTeamNameEnKey = "CompShortTeamNameEn"
    static private let CompTeamNameRuKey = "CompTeamNameRu"
    static private let CompTeamNameEnKey = "CompTeamNameEn"
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
    static private let TeamDefReboundKey = "TeamDefRebound"
    static private let TeamOffReboundKey = "TeamOffRebound"

    static func gameStatisticsWithDict(dict: [String:AnyObject], gameId: Int, inContext context: NSManagedObjectContext) -> GameStatistics? {
        var res: GameStatistics?
        
        // Статистика команды
        if let teamId = dict[TeamIdKey] as? NSNumber {
            let fetchRequest = NSFetchRequest(entityName: GameStatistics.entityName())
            fetchRequest.predicate = NSPredicate(format: "game.objectId = \(gameId) AND team.objectId = %@", teamId)
            do {
                res = try context.executeFetchRequest(fetchRequest).first as? GameStatistics
                
                if res == nil {
                    res = GameStatistics(entity: NSEntityDescription.entityForName(GameStatistics.entityName(), inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
                    
                    if let teamGameDict = dict[TeamNameKey] as? [String:AnyObject] {
                        var teamDict = [String:AnyObject]()
                        teamDict[Team.TeamIdKey] = teamGameDict[TeamIdKey] as? Int
                        teamDict[Team.ShortTeamNameRuKey] = teamGameDict[CompTeamShortNameRuKey] as? String
                        teamDict[Team.ShortTeamNameEnKey] = teamGameDict[CompShortTeamNameEnKey] as? String
                        teamDict[Team.TeamNameRuKey] = teamGameDict[CompTeamNameRuKey] as? String
                        teamDict[Team.TeamNameEnKey] = teamGameDict[CompTeamNameEnKey] as? String
                        res?.team = Team.teamWithDict(teamDict, inContext: context)
                    }
                }
            } catch {}
        } else if let personId = dict[Player.PlayerIdKey] as? NSNumber {
            // Статистика игрока
            let fetchRequest = NSFetchRequest(entityName: GameStatistics.entityName())
            fetchRequest.predicate = NSPredicate(format: "game.objectId = \(gameId) AND player.objectId = %@", personId)
            do {
                res = try context.executeFetchRequest(fetchRequest).first as? GameStatistics
                
                if res == nil {
                    res = GameStatistics(entity: NSEntityDescription.entityForName(GameStatistics.entityName(), inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
                    
                    var playerDict = [String:AnyObject]()
                    playerDict[Player.PlayerIdKey] = personId
                    var personInfo = [String:AnyObject]()
                    personInfo[Player.PersonLastNameRuKey] = dict[LastNameRuKey] as? String
                    personInfo[Player.PersonLastNameEnKey] = dict[LastNameEnKey] as? String
                    personInfo[Player.PersonFirstNameRuKey] = dict[FirstNameRuKey] as? String
                    personInfo[Player.PersonFirstNameEnKey] = dict[FirstNameEnKey] as? String
                    personInfo[Player.PersonBirthdayKey] = dict[PersonBirthKey] as? String
                    personInfo[Player.PersonHeightKey] = dict[HeightKey] as? Int
                    personInfo[Player.PersonWeightKey] = dict[WeightKey] as? Int
                    playerDict[Player.PersonInfoKey] = personInfo
                    res?.player = Player.playerWithDict(playerDict, inContext: context)
                }
            } catch {}
        }
        
        res?.teamNumber = dict[TeamNumberKey] as? Int
        res?.playerNumber = dict[PlayerNumberKey] as? Int
        res?.fouls = dict[FoulsKey] as? Int
        res?.opponentFouls = dict[OpponentFoulsKey] as? Int
        res?.isStart = dict[IsStartKey] as? Bool
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
        res?.teamOffensiveRebounds = dict[TeamOffReboundKey] as? Int ?? 0
        res?.teamDefensiveRebounds = dict[TeamDefReboundKey] as? Int ?? 0
        res?.turnovers = dict[TurnoversKey] as? Int ?? 0
        res?.blocks = dict[BlocksKey] as? Int ?? 0
        res?.plusMinus = dict[PlusMinusKey] as? Int ?? 0
        res?.seconds = dict[SecondsKey] as? Int ?? 0
        
        return res
    }
}