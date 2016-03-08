//
//  Game+CoreDataProperties.swift
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

extension Game {

    @NSManaged var date: NSDate?
    @NSManaged var objectId: NSNumber?
    @NSManaged var scoreA: NSNumber?
    @NSManaged var scoreByPeriods: String?
    @NSManaged var venueEn: String?
    @NSManaged var venueRu: String?
    @NSManaged var scoreB: NSNumber?
    @NSManaged var teamA: Team?
    @NSManaged var teamB: Team?

}
