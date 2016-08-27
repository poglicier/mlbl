//
//  TeamRoundRank+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 26.08.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TeamRoundRank {

    @NSManaged var place: NSNumber?
    @NSManaged var standingsGoalPlus: NSNumber?
    @NSManaged var standingsGoalMinus: NSNumber?
    @NSManaged var standingWin: NSNumber?
    @NSManaged var standingLose: NSNumber?
    @NSManaged var standingPoints: NSNumber?
    @NSManaged var team: Team?
    @NSManaged var competition: Competition?

}
