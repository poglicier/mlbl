//
//  Player.swift
//  
//
//  Created by Valentin Shamardin on 05.03.16.
//
//

import Foundation
import CoreData


public class Player: NSManagedObject {

    static let PlayerIdKey = "PersonID"
    static let PersonInfoKey = "PersonInfo"
    static let PersonLastNameRuKey = "PersonLastNameRu"
    static let PersonFirstNameRuKey = "PersonFirstNameRu"
    static let PersonLastNameEnKey = "PersonLastNameEn"
    static let PersonFirstNameEnKey = "PersonFirstNameEn"
    static fileprivate let PlayerNumberKey = "PlayerNumber"
    static fileprivate let PersonGenderKey = "PersonGender"
    static let PersonBirthdayKey = "PersonBirthday"
    static let PersonHeightKey = "PersonHeight"
    static let PersonWeightKey = "PersonWeight"
    static fileprivate let PersonTeamNameKey = "TeamName"
    static fileprivate let PersonCompTeamShortNameRuKey = "CompTeamShortNameRu"
    static fileprivate let PersonCompTeamShortNameEnKey = "CompTeamShortNameEn"
    static fileprivate let PersonCompTeamNameRuKey = "CompTeamNameRu"
    static fileprivate let PersonCompTeamNameEnKey = "CompTeamNameEn"
    static fileprivate let PersonPlayersKey = "Players"
    static fileprivate let PersonPlayerPositionKey = "Position"
    static fileprivate let PersonPlayerPositionShortEnKey = "PosShortNameEn"
    static fileprivate let PersonPlayerPositionEnKey = "PosNameEn"
    static fileprivate let PersonPlayerPositionShortRuKey = "PosShortNameRu"
    static fileprivate let PersonPlayerPositionRuKey = "PosNameRu"
    
    @discardableResult
    static func playerWithDict(_ dict: [String:AnyObject], inContext context: NSManagedObjectContext) -> Player? {
        var res: Player?
        
        if let objectId = dict[PlayerIdKey] as? NSNumber {
            let fetchRequest = NSFetchRequest<Player>(entityName: Player.entityName())
            fetchRequest.predicate = NSPredicate(format: "objectId = %@", objectId)
            do {
                res = try context.fetch(fetchRequest).first
                
                if res == nil {
                    res = Player(entity: NSEntityDescription.entity(forEntityName: Player.entityName(), in: context)!, insertInto: context)
                    res?.objectId = objectId
                }
            } catch {}
            
            if let personInfo = dict[PersonInfoKey] as? [String:AnyObject] {
                res?.firstNameRu = personInfo[PersonFirstNameRuKey] as? String
                res?.lastNameRu = personInfo[PersonLastNameRuKey] as? String
                res?.firstNameEn = personInfo[PersonFirstNameEnKey] as? String
                res?.lastNameEn = personInfo[PersonLastNameEnKey] as? String
                
                if res?.lastNameRu == nil &&
                    res?.lastNameEn == nil {
                    return nil
                }
                
                if let gender = personInfo[PersonGenderKey] as? Int {
                    res?.gender = gender as NSNumber?
                }
                if let height = personInfo[PersonHeightKey] as? Int {
                    res?.height = height as NSNumber?
                }
                if let weight = personInfo[PersonWeightKey] as? Int {
                    res?.weight = weight as NSNumber?
                }
                if let birthIntervalString = personInfo[PersonBirthdayKey] as? NSString {
                    if let birthInterval = Double((birthIntervalString.replacingOccurrences(of: "/Date(", with: "") as NSString).replacingOccurrences(of: ")/", with: "")) {
                        res?.birth = Date(timeIntervalSince1970: birthInterval/1000) as NSDate?
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
            
            res?.playerNumber = dict[PlayerNumberKey] as? Int as NSNumber?
            
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
