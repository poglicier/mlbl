//
//  PlayerStatistics+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 11.10.16.
//
//

import Foundation
import CoreData

extension PlayerStatistics {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayerStatistics> {
        return NSFetchRequest<PlayerStatistics>(entityName: "PlayerStatistics");
    }

    @NSManaged public var assists: NSNumber?
    @NSManaged public var blocks: NSNumber?
    @NSManaged public var defensiveRebounds: NSNumber?
    @NSManaged public var fouls: NSNumber?
    @NSManaged public var goal1: NSNumber?
    @NSManaged public var goal2: NSNumber?
    @NSManaged public var goal3: NSNumber?
    @NSManaged public var offensiveRebounds: NSNumber?
    @NSManaged public var opponentFouls: NSNumber?
    @NSManaged public var plusMinus: NSNumber?
    @NSManaged public var points: NSNumber?
    @NSManaged public var seconds: NSNumber?
    @NSManaged public var shot1: NSNumber?
    @NSManaged public var shot2: NSNumber?
    @NSManaged public var shot3: NSNumber?
    @NSManaged public var steals: NSNumber?
    @NSManaged public var turnovers: NSNumber?
    @NSManaged public var game: Game?
    @NSManaged public var player: Player?
    @NSManaged public var teamA: Team?
    @NSManaged public var teamB: Team?

}
