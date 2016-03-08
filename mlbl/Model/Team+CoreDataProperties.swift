//
//  Team+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 07.03.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Team {

    @NSManaged var objectId: NSNumber?
    @NSManaged var nameRu: String?
    @NSManaged var nameEn: String?
    @NSManaged var regionNameRu: String?
    @NSManaged var regionNameEn: String?
    @NSManaged var guestGames: NSSet?
    @NSManaged var homeGames: NSSet?
    @NSManaged var players: NSSet?

}
