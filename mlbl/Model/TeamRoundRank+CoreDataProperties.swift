//
//  TeamRoundRank+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 10.10.16.
//
//

import Foundation
import CoreData

extension TeamRoundRank {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TeamRoundRank> {
        return NSFetchRequest<TeamRoundRank>(entityName: "TeamRoundRank");
    }

    @NSManaged public var place: NSNumber?
    @NSManaged public var standingLose: NSNumber?
    @NSManaged public var standingPoints: NSNumber?
    @NSManaged public var standingsGoalMinus: NSNumber?
    @NSManaged public var standingsGoalPlus: NSNumber?
    @NSManaged public var standingWin: NSNumber?
    @NSManaged public var competition: Competition?
    @NSManaged public var team: Team?

}
