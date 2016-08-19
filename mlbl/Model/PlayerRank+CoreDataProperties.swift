//
//  PlayerRank+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 17.08.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PlayerRank {

    @NSManaged var res: NSNumber?
    @NSManaged var player: Player?
    @NSManaged var parameter: StatParameter?

}
