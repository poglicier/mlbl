//
//  Game+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 28.07.16.
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
    @NSManaged var scoreB: NSNumber?
    @NSManaged var scoreByPeriods: String?
    @NSManaged var venueEn: String?
    @NSManaged var venueRu: String?
    @NSManaged var shortTeamNameAru: String?
    @NSManaged var shortTeamNameAen: String?
    @NSManaged var teamNameAru: String?
    @NSManaged var teamNameAen: String?
    @NSManaged var shortTeamNameBen: String?
    @NSManaged var shortTeamNameBru: String?
    @NSManaged var teamNameBen: String?
    @NSManaged var teamNameBru: String?
    @NSManaged var teamAId: NSNumber?
    @NSManaged var teamBId: NSNumber?
    @NSManaged var statistics: NSSet?

}
