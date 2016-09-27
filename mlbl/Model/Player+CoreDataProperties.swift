//
//  Player+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 05.09.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Player {

    @NSManaged var birth: Date?
    @NSManaged var firstNameEn: String?
    @NSManaged var firstNameRu: String?
    @NSManaged var gender: NSNumber?
    @NSManaged var height: NSNumber?
    @NSManaged var lastNameEn: String?
    @NSManaged var lastNameRu: String?
    @NSManaged var objectId: NSNumber?
    @NSManaged var playerNumber: NSNumber?
    @NSManaged var positionEn: String?
    @NSManaged var positionRu: String?
    @NSManaged var positionShortEn: String?
    @NSManaged var positionShortRu: String?
    @NSManaged var weight: NSNumber?
    @NSManaged var gameStatistics: NSSet?
    @NSManaged var ranks: NSSet?
    @NSManaged var team: Team?
    @NSManaged var teamStatistics: TeamStatistics?
    @NSManaged var seasonTeams: NSSet?

}
