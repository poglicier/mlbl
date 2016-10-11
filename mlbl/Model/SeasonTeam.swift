//
//  SeasonTeam.swift
//  
//
//  Created by Valentin Shamardin on 05.09.16.
//
//

import Foundation
import CoreData

public class SeasonTeam: NSManagedObject {

    fileprivate static let TeamKey = "Team"
    fileprivate static let TeamIdKey = "TeamID"
    fileprivate static let TeamShortNameRuKey = "TeamShortNameRu"
    fileprivate static let TeamShortNameEnKey = "TeamShortNameEn"
    fileprivate static let TeamNameRuKey = "TeamNameRu"
    fileprivate static let TeamNameEnKey = "TeamNameEn"
    fileprivate static let CompKey = "Comp"
    fileprivate static let CompAbcNameRuKey = "CompAbcNameRu"
    fileprivate static let CompAbcNameEnKey = "CompAbcNameEn"
    fileprivate static let CompFullNameRuKey = "CompFullNameRu"
    fileprivate static let CompFullNameEnKey = "CompFullNameEn"
    
    @discardableResult
    static func seasonTeamWithDict(_ dict: [String:AnyObject], inContext context: NSManagedObjectContext) -> SeasonTeam? {
        var res: SeasonTeam?
        
        if let teamDict = dict[TeamKey] as? [String:AnyObject] {
            var fixedTeamDict = [String:AnyObject]()
            fixedTeamDict[Team.TeamIdKey] = teamDict[TeamIdKey] as? Int as AnyObject?
            fixedTeamDict[Team.ShortTeamNameRuKey] = teamDict[TeamShortNameRuKey] as? String as AnyObject?
            fixedTeamDict[Team.ShortTeamNameEnKey] = teamDict[TeamShortNameEnKey] as? String as AnyObject?
            fixedTeamDict[Team.TeamNameRuKey] = teamDict[TeamNameRuKey] as? String as AnyObject?
            fixedTeamDict[Team.TeamNameEnKey] = teamDict[TeamNameEnKey] as? String as AnyObject?
            
            if let team = Team.teamWithDict(fixedTeamDict, inContext: context) {
                if let compDict = dict[CompKey] as? [String:AnyObject] {
                    res = SeasonTeam.init(entity: NSEntityDescription.entity(forEntityName: SeasonTeam.entityName(), in: context)!, insertInto: context)
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
