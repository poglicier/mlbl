//
//  PlayerRank+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 10.10.16.
//
//

import Foundation
import CoreData

extension PlayerRank {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayerRank> {
        return NSFetchRequest<PlayerRank>(entityName: "PlayerRank");
    }

    @NSManaged public var res: NSNumber?
    @NSManaged public var parameter: StatParameter?
    @NSManaged public var player: Player?

}
