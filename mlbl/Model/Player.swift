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
            }
        }
        return res
    }
}