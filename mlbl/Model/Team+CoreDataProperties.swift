//
//  Team+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 05.03.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Team {

    @NSManaged var objectId: NSNumber?
    @NSManaged var homeGames: NSSet?
    @NSManaged var guestGames: NSSet?
    @NSManaged var players: NSSet?

}
