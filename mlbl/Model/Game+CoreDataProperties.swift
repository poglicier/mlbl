//
//  Game+CoreDataProperties.swift
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

extension Game {

    @NSManaged var objectId: NSNumber?
    @NSManaged var date: NSDate?
    @NSManaged var venueRu: String?
    @NSManaged var venueEn: NSNumber?
    @NSManaged var score: String?
    @NSManaged var scoreByPeriods: String?
    @NSManaged var teamA: Team?
    @NSManaged var teamB: Team?

}
