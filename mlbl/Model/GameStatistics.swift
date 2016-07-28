//
//  GameStatistics.swift
//  
//
//  Created by Valentin Shamardin on 27.07.16.
//
//

import Foundation
import CoreData

private let TeamIdKey = "TeamID"
private let TeamNameKey = "TeamName"
private let CompTeamShortNameRuKey = "CompTeamShortNameRu"
private let CompShortTeamNameEnKey = "CompShortTeamNameEn"
private let CompTeamNameRuKey = "CompTeamNameRu"
private let CompTeamNameEnKey = "CompTeamNameEn"
private let PointsKey = "Points"
private let Shot1Key = "Shot1"
private let Shot2Key = "Shot2"
private let Shot3Key = "Shot3"
private let Goal1Key = "Goal1"
private let Goal2Key = "Goal2"
private let Goal3Key = "Goal3"
private let AssistsKey = "Assist"
private let DefReboundsKey = "DefRebound"
private let OffReboundsKey = "OffRebound"
private let StealsKey = "Steal"
private let TurnoversKey = "Turnover"
private let SecondsKey = "Seconds"
private let PlusMinusKey = "PlusMinus"
private let BlocksKey = "Blocks"
private let TeamNumberKey = "TeamNumber"

class GameStatistics: NSManagedObject {

    static func gameStatisticsWithDict(dict: [String:AnyObject], gameId: Int, inContext context: NSManagedObjectContext) -> GameStatistics? {
        var res: GameStatistics?
        
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
                
                res?.teamNumber = dict[TeamNumberKey] as? Int
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
            } catch {}
        }
        
        return res
    }
}