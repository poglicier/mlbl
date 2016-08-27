//
//  TeamRoundRank.swift
//  
//
//  Created by Valentin Shamardin on 26.08.16.
//
//

import Foundation
import CoreData

class TeamRoundRank: NSManagedObject {

    static private let CompTeamIDKey = "TeamID"
    static private let CompTeamNameKey = "CompTeamName"
    static private let CompTeamShortNameRuKey = "CompTeamShortNameRu"
    static private let CompTeamShortNameEnKey = "CompTeamShortNameEn"
    static private let CompTeamNameRuKey = "CompTeamNameRu"
    static private let CompTeamNameEnKey = "CompTeamNameEn"
    static private let CompTeamStandingsKey = "CompTeamStandings"
    static private let StandingGoalPlusKey = "StandingGoalPlus"
    static private let StandingGoalMinusKey = "StandingGoalMinus"
    static private let StandingPointsKey = "StandingPoints"
    static private let StandingWinKey = "StandingWin"
    static private let StandingLoseKey = "StandingLose"
    static private let CompTeamPlaceKey = "CompTeamPlace"
    
    static func rankWithDict(dict: [String:AnyObject], compId: Int, inContext context: NSManagedObjectContext) -> TeamRoundRank? {
        var res: TeamRoundRank?
        
        if let compTeamDict = dict[CompTeamNameKey] as? [String:AnyObject] {
            var teamDict = [String:AnyObject]()
            teamDict[Team.TeamIdKey] = compTeamDict[CompTeamIDKey]
            teamDict[Team.ShortTeamNameEnKey] = compTeamDict[CompTeamShortNameEnKey]
            teamDict[Team.ShortTeamNameRuKey] = compTeamDict[CompTeamShortNameRuKey]
            teamDict[Team.TeamNameEnKey] = compTeamDict[CompTeamNameEnKey]
            teamDict[Team.TeamNameRuKey] = compTeamDict[CompTeamNameRuKey]
            
            if let team = Team.teamWithDict(teamDict, inContext: context) {
                let fetchRequest = NSFetchRequest(entityName: TeamRoundRank.entityName())
                fetchRequest.predicate = NSPredicate(format: "competition.objectId = %d AND team = %@", compId, team)
                do {
                    res = try context.executeFetchRequest(fetchRequest).first as? TeamRoundRank
                    
                    if res == nil {
                        res = TeamRoundRank(entity: NSEntityDescription.entityForName(TeamRoundRank.entityName(), inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
                        res?.team = team
                        
                        let parameterRequest = NSFetchRequest(entityName: Competition.entityName())
                        parameterRequest.predicate = NSPredicate(format: "objectId = %d", compId)
                        do {
                            res?.competition = (try context.executeFetchRequest(parameterRequest) as! [Competition]).first
                        } catch {
                            res = nil
                        }
                    }
                    
                    if let standings = (dict[CompTeamStandingsKey] as? [[String:AnyObject]])?.first {
                        res?.standingWin = standings[StandingWinKey] as? Int
                        res?.standingLose = standings[StandingLoseKey] as? Int
                        res?.standingPoints = standings[StandingPointsKey] as? Int
                        res?.standingsGoalPlus = standings[StandingGoalPlusKey] as? Int
                        res?.standingsGoalMinus = standings[StandingGoalMinusKey] as? Int
                    }
                    
                    res?.place = dict[CompTeamPlaceKey] as? Int
                } catch {}
            }
        }
        
        return res
    }
}