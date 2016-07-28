//
//  Team+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 27.07.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Team {

    @NSManaged var nameEn: String?
    @NSManaged var nameRu: String?
    @NSManaged var objectId: NSNumber?
    @NSManaged var regionNameEn: String?
    @NSManaged var regionNameRu: String?
    @NSManaged var shortNameEn: String?
    @NSManaged var shortNameRu: String?
    @NSManaged var players: NSSet?
    @NSManaged var gameStatistics: NSSet?

}
