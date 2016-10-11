//
//  TeamStatistics+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 10.10.16.
//
//

import Foundation
import CoreData

extension TeamStatistics {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TeamStatistics> {
        return NSFetchRequest<TeamStatistics>(entityName: "TeamStatistics");
    }

    @NSManaged public var assists: NSNumber?
    @NSManaged public var blocks: NSNumber?
    @NSManaged public var defensiveRebounds: NSNumber?
    @NSManaged public var fouls: NSNumber?
    @NSManaged public var games: NSNumber?
    @NSManaged public var goal1: NSNumber?
    @NSManaged public var goal2: NSNumber?
    @NSManaged public var goal3: NSNumber?
    @NSManaged public var offensiveRebounds: NSNumber?
    @NSManaged public var opponentFouls: NSNumber?
    @NSManaged public var playerNumber: NSNumber?
    @NSManaged public var plusMinus: NSNumber?
    @NSManaged public var points: NSNumber?
    @NSManaged public var seconds: NSNumber?
    @NSManaged public var shot1: NSNumber?
    @NSManaged public var shot2: NSNumber?
    @NSManaged public var shot3: NSNumber?
    @NSManaged public var steals: NSNumber?
    @NSManaged public var teamDefensiveRebounds: NSNumber?
    @NSManaged public var teamNumber: NSNumber?
    @NSManaged public var teamOffensiveRebounds: NSNumber?
    @NSManaged public var turnovers: NSNumber?
    @NSManaged public var player: Player?
    @NSManaged public var team: Team?

}
