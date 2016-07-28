//
//  Player+CoreDataProperties.swift
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

extension Player {

    @NSManaged var birth: NSDate?
    @NSManaged var firstNameEn: String?
    @NSManaged var firstNameRu: String?
    @NSManaged var gender: NSNumber?
    @NSManaged var height: NSNumber?
    @NSManaged var lastNameEn: String?
    @NSManaged var lastNameRu: String?
    @NSManaged var objectId: NSNumber?
    @NSManaged var positionEn: String?
    @NSManaged var positionRu: String?
    @NSManaged var positionShortEn: String?
    @NSManaged var positionShortRu: String?
    @NSManaged var weight: NSNumber?
    @NSManaged var team: Team?
    @NSManaged var gameStatistics: NSSet?

}
