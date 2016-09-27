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

    static fileprivate let PersonKey = "Person"
    static fileprivate let ResKey = "Res"
    
    @discardableResult
    static func rankWithDict(_ dict: [String:AnyObject], paramId: Int, inContext context: NSManagedObjectContext) -> PlayerRank? {
        var res: PlayerRank?
        
        if let personDict = dict[PersonKey] as? [String:AnyObject] {
            var playerDict = [String:AnyObject]()
            playerDict[Player.PlayerIdKey] = personDict[Player.PlayerIdKey]
            playerDict[Player.PersonInfoKey] = personDict as AnyObject?
            
            if let player = Player.playerWithDict(playerDict, inContext: context) {
                let fetchRequest = NSFetchRequest<PlayerRank>(entityName: PlayerRank.entityName())
                fetchRequest.predicate = NSPredicate(format: "parameter.objectId = %d AND player = %@", paramId, player)
                do {
                    res = try context.fetch(fetchRequest).first
                    
                    if res == nil {
                        res = PlayerRank(entity: NSEntityDescription.entity(forEntityName: PlayerRank.entityName(), in: context)!, insertInto: context)
                        res?.player = player
                        
                        let parameterRequest = NSFetchRequest<StatParameter>(entityName: StatParameter.entityName())
                        parameterRequest.predicate = NSPredicate(format: "objectId = %d", paramId)
                        do {
                            res?.parameter = try context.fetch(parameterRequest).first
                        } catch {
                            res = nil
                        }
                    }
                    
                    res?.res = dict[ResKey] as? CGFloat as NSNumber?
                } catch {}
            }
        }
        
        return res
    }
}
