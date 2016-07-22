//
//  Player.swift
//  
//
//  Created by Valentin Shamardin on 05.03.16.
//
//

import Foundation
import CoreData


class Player: NSManagedObject {

    static private let PlayerIdKey = "PersonID"
    static private let PersonInfoKey = "PersonInfo"
    static private let PersonLastNameRuKey = "PersonLastNameRu"
    static private let PersonFirstNameRuKey = "PersonFirstNameRu"
    static private let PersonLastNameEnKey = "PersonLastNameEn"
    static private let PersonFirstNameEnKey = "PersonFirstNameEn"
    static private let PersonGenderKey = "PersonGender"
    static private let PersonBirthdayKey = "PersonBirthday"
    static private let PersonHeightKey = "PersonHeight"
    static private let PersonWeightKey = "PersonWeight"
    static private let PersonTeamNameKey = "TeamName"
    static private let PersonCompTeamShortNameRuKey = "CompTeamShortNameRu"
    static private let PersonCompTeamShortNameEnKey = "CompTeamShortNameEn"
    static private let PersonCompTeamNameRuKey = "CompTeamNameRu"
    static private let PersonCompTeamNameEnKey = "CompTeamNameEn"
    static private let PersonPlayersKey = "Players"
    static private let PersonPlayerPositionKey = "Position"
    static private let PersonPlayerPositionShortEnKey = "PosShortNameEn"
    static private let PersonPlayerPositionEnKey = "PosNameEn"
    static private let PersonPlayerPositionShortRuKey = "PosShortNameRu"
    static private let PersonPlayerPositionRuKey = "PosNameRu"
    
    static func playerWithDict(dict: [String:AnyObject], inContext context: NSManagedObjectContext) -> Player? {
        var res: Player?
        
        if let objectId = dict[PlayerIdKey] as? NSNumber {
            let fetchRequest = NSFetchRequest(entityName: Player.entityName())
            fetchRequest.predicate = NSPredicate(format: "objectId = %@", objectId)
            do {
                res = try context.executeFetchRequest(fetchRequest).first as? Player
                
                if res == nil {
                    res = Player(entity: NSEntityDescription.entityForName(Player.entityName(), inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
                    res?.objectId = objectId
                }
            } catch {}
            
            if let personInfo = dict[PersonInfoKey] as? [String:AnyObject] {
                res?.firstNameRu = personInfo[PersonFirstNameRuKey] as? String
                res?.lastNameRu = personInfo[PersonLastNameRuKey] as? String
                res?.firstNameEn = personInfo[PersonFirstNameEnKey] as? String
                res?.lastNameEn = personInfo[PersonLastNameEnKey] as? String
                res?.gender = personInfo[PersonGenderKey] as? Int
                res?.height = personInfo[PersonHeightKey] as? Int
                res?.weight = personInfo[PersonWeightKey] as? Int
                if let birthIntervalString = personInfo[PersonBirthdayKey] as? NSString {
                    if let birthInterval = Double((birthIntervalString.stringByReplacingOccurrencesOfString("/Date(", withString: "") as NSString).stringByReplacingOccurrencesOfString(")/", withString: "")) {
                        res?.birth = NSDate(timeIntervalSince1970: birthInterval/1000)
                    }
                }
                
                if let playersDicts = personInfo[PersonPlayersKey] as? [[String:AnyObject]] {
                    if let playerDict = playersDicts.first {
                        if let positionDict = playerDict[PersonPlayerPositionKey] as? [String:AnyObject] {
                            res?.positionEn = positionDict[PersonPlayerPositionEnKey] as? String
                            res?.positionRu = positionDict[PersonPlayerPositionRuKey] as? String
                            res?.positionShortEn = positionDict[PersonPlayerPositionShortEnKey] as? String
                            res?.positionShortRu = positionDict[PersonPlayerPositionShortRuKey] as? String
                        }
                    }
                }
            }
            
            if let teamNameDict = dict[PersonTeamNameKey] as? [String:AnyObject] {
                var teamDict = [String:AnyObject]()
                teamDict[Team.TeamIdKey] = teamNameDict[Team.TeamIdKey]
                teamDict[Team.ShortTeamNameRuKey] = teamNameDict[PersonCompTeamShortNameRuKey]
                teamDict[Team.ShortTeamNameEnKey] = teamNameDict[PersonCompTeamShortNameEnKey]
                teamDict[Team.TeamNameRuKey] = teamNameDict[PersonCompTeamNameRuKey]
                teamDict[Team.TeamNameEnKey] = teamNameDict[PersonCompTeamNameEnKey]
                
                res?.team = Team.teamWithDict(teamDict, inContext: context)
            }
        }
        return res
    }
}