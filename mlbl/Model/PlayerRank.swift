//
//  PlayerRank.swift
//  
//
//  Created by Valentin Shamardin on 17.08.16.
//
//

import Foundation
import CoreData

class PlayerRank: NSManagedObject {

    static private let PersonKey = "Person"
    static private let ResKey = "Res"
    
    static func rankWithDict(dict: [String:AnyObject], paramId: Int, inContext context: NSManagedObjectContext) -> PlayerRank? {
        var res: PlayerRank?
        
        if let personDict = dict[PersonKey] as? [String:AnyObject] {
            var playerDict = [String:AnyObject]()
            playerDict[Player.PlayerIdKey] = personDict[Player.PlayerIdKey]
            playerDict[Player.PersonInfoKey] = personDict
            
            if let player = Player.playerWithDict(playerDict, inContext: context) {
                let fetchRequest = NSFetchRequest(entityName: PlayerRank.entityName())
                fetchRequest.predicate = NSPredicate(format: "parameter.objectId = %d AND player = %@", paramId, player)
                do {
                    res = try context.executeFetchRequest(fetchRequest).first as? PlayerRank
                    
                    if res == nil {
                        res = PlayerRank(entity: NSEntityDescription.entityForName(PlayerRank.entityName(), inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
                        res?.player = player
                        
                        let parameterRequest = NSFetchRequest(entityName: StatParameter.entityName())
                        parameterRequest.predicate = NSPredicate(format: "objectId = %d", paramId)
                        do {
                            res?.parameter = (try context.executeFetchRequest(parameterRequest) as! [StatParameter]).first
                        } catch {
                            res = nil
                        }
                    }
                    
                    res?.res = dict[ResKey] as? CGFloat
                } catch {}
            }
        }
        
        return res
    }
}