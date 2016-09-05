//
//  SeasonTeam.swift
//  
//
//  Created by Valentin Shamardin on 05.09.16.
//
//

import Foundation
import CoreData

class SeasonTeam: NSManagedObject {

    private static let TeamKey = "Team"
    private static let TeamIdKey = "TeamID"
    private static let TeamShortNameRuKey = "TeamShortNameRu"
    private static let TeamShortNameEnKey = "TeamShortNameEn"
    private static let TeamNameRuKey = "TeamNameRu"
    private static let TeamNameEnKey = "TeamNameEn"
    private static let CompKey = "Comp"
    private static let CompAbcNameRuKey = "CompAbcNameRu"
    private static let CompAbcNameEnKey = "CompAbcNameEn"
    private static let CompFullNameRuKey = "CompFullNameRu"
    private static let CompFullNameEnKey = "CompFullNameEn"
    
    static func seasonTeamWithDict(dict: [String:AnyObject], inContext context: NSManagedObjectContext) -> SeasonTeam? {
        var res: SeasonTeam?
        
        if let teamDict = dict[TeamKey] as? [String:AnyObject] {
            var fixedTeamDict = [String:AnyObject]()
            fixedTeamDict[Team.TeamIdKey] = teamDict[TeamIdKey] as? Int
            fixedTeamDict[Team.ShortTeamNameRuKey] = teamDict[TeamShortNameRuKey] as? String
            fixedTeamDict[Team.ShortTeamNameEnKey] = teamDict[TeamShortNameEnKey] as? String
            fixedTeamDict[Team.TeamNameRuKey] = teamDict[TeamNameRuKey] as? String
            fixedTeamDict[Team.TeamNameEnKey] = teamDict[TeamNameEnKey] as? String
            
            if let team = Team.teamWithDict(fixedTeamDict, inContext: context) {
                if let compDict = dict[CompKey] as? [String:AnyObject] {
                    res = SeasonTeam.init(entity: NSEntityDescription.entityForName(SeasonTeam.entityName(), inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
                    res?.team = team
                    
                    res?.abcNameEn = compDict[CompAbcNameEnKey] as? String
                    res?.abcNameRu = compDict[CompAbcNameRuKey] as? String
                    res?.nameEn = compDict[CompFullNameEnKey] as? String
                    res?.nameRu = compDict[CompFullNameRuKey] as? String
                }
            }
        }
        
        return res
    }
}