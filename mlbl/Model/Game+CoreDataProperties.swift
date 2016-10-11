//
//  Game+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 10.10.16.
//
//

import Foundation
import CoreData

extension Game {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Game> {
        return NSFetchRequest<Game>(entityName: "Game");
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var objectId: NSNumber?
    @NSManaged public var scoreA: NSNumber?
    @NSManaged public var scoreB: NSNumber?
    @NSManaged public var scoreByPeriods: String?
    @NSManaged public var shortTeamNameAen: String?
    @NSManaged public var shortTeamNameAru: String?
    @NSManaged public var shortTeamNameBen: String?
    @NSManaged public var shortTeamNameBru: String?
    @NSManaged public var status: NSNumber?
    @NSManaged public var teamAId: NSNumber?
    @NSManaged public var teamBId: NSNumber?
    @NSManaged public var teamNameAen: String?
    @NSManaged public var teamNameAru: String?
    @NSManaged public var teamNameBen: String?
    @NSManaged public var teamNameBru: String?
    @NSManaged public var venueEn: String?
    @NSManaged public var venueRu: String?
    @NSManaged public var playoffSerie: PlayoffSerie?
    @NSManaged public var statistics: NSSet?
    @NSManaged public var playerStatistics: NSSet?

}

// MARK: Generated accessors for statistics
extension Game {

    @objc(addStatisticsObject:)
    @NSManaged public func addToStatistics(_ value: GameStatistics)

    @objc(removeStatisticsObject:)
    @NSManaged public func removeFromStatistics(_ value: GameStatistics)

    @objc(addStatistics:)
    @NSManaged public func addToStatistics(_ values: NSSet)

    @objc(removeStatistics:)
    @NSManaged public func removeFromStatistics(_ values: NSSet)

}

// MARK: Generated accessors for playerStatistics
extension Game {

    @objc(addPlayerStatisticsObject:)
    @NSManaged public func addToPlayerStatistics(_ value: GameStatistics)

    @objc(removePlayerStatisticsObject:)
    @NSManaged public func removeFromPlayerStatistics(_ value: GameStatistics)

    @objc(addPlayerStatistics:)
    @NSManaged public func addToPlayerStatistics(_ values: NSSet)

    @objc(removePlayerStatistics:)
    @NSManaged public func removeFromPlayerStatistics(_ values: NSSet)

}
