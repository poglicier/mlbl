//
//  TeamRoundRank.swift
//  
//
//  Created by Valentin Shamardin on 26.08.16.
//
//

import Foundation
import CoreData

public class TeamRoundRank: NSManagedObject {

    static fileprivate let CompTeamIDKey = "TeamID"
    static fileprivate let CompTeamNameKey = "CompTeamName"
    static fileprivate let CompTeamShortNameRuKey = "CompTeamShortNameRu"
    static fileprivate let CompTeamShortNameEnKey = "CompTeamShortNameEn"
    static fileprivate let CompTeamNameRuKey = "CompTeamNameRu"
    static fileprivate let CompTeamNameEnKey = "CompTeamNameEn"
    static fileprivate let CompTeamStandingsKey = "CompTeamStandings"
    static fileprivate let StandingGoalPlusKey = "StandingGoalPlus"
    static fileprivate let StandingGoalMinusKey = "StandingGoalMinus"
    static fileprivate let StandingPointsKey = "StandingPoints"
    static fileprivate let StandingWinKey = "StandingWin"
    static fileprivate let StandingLoseKey = "StandingLose"
    static fileprivate let CompTeamPlaceKey = "CompTeamPlace"
    
    @discardableResult
    static func rankWithDict(_ dict: [String:AnyObject], compId: Int, inContext context: NSManagedObjectContext) -> TeamRoundRank? {
        var res: TeamRoundRank?
        
        if let compTeamDict = dict[CompTeamNameKey] as? [String:AnyObject] {
            var teamDict = [String:AnyObject]()
            teamDict[Team.TeamIdKey] = compTeamDict[CompTeamIDKey]
            teamDict[Team.ShortTeamNameEnKey] = compTeamDict[CompTeamShortNameEnKey]
            teamDict[Team.ShortTeamNameRuKey] = compTeamDict[CompTeamShortNameRuKey]
            teamDict[Team.TeamNameEnKey] = compTeamDict[CompTeamNameEnKey]
            teamDict[Team.TeamNameRuKey] = compTeamDict[CompTeamNameRuKey]
            
            if let team = Team.teamWithDict(teamDict, inContext: context) {
                let fetchRequest = NSFetchRequest<TeamRoundRank>(entityName: TeamRoundRank.entityName())
                fetchRequest.predicate = NSPredicate(format: "competition.objectId = %d AND team = %@", compId, team)
                do {
                    res = try context.fetch(fetchRequest).first
                    
                    if res == nil {
                        res = TeamRoundRank(entity: NSEntityDescription.entity(forEntityName: TeamRoundRank.entityName(), in: context)!, insertInto: context)
                        res?.team = team
                        
                        let parameterRequest = NSFetchRequest<Competition>(entityName: Competition.entityName())
                        parameterRequest.predicate = NSPredicate(format: "objectId = %d", compId)
                        do {
                            res?.competition = try context.fetch(parameterRequest).first
                        } catch {
                            res = nil
                        }
                    }
                    
                    if let standings = (dict[CompTeamStandingsKey] as? [[String:AnyObject]])?.first {
                        res?.standingWin = standings[StandingWinKey] as? Int as NSNumber?
                        res?.standingLose = standings[StandingLoseKey] as? Int as NSNumber?
                        res?.standingPoints = standings[StandingPointsKey] as? Int as NSNumber?
                        res?.standingsGoalPlus = standings[StandingGoalPlusKey] as? Int as NSNumber?
                        res?.standingsGoalMinus = standings[StandingGoalMinusKey] as? Int as NSNumber?
                    }
                    
                    res?.place = dict[CompTeamPlaceKey] as? Int as NSNumber?
                } catch {}
            }
        }
        
        return res
    }
}
