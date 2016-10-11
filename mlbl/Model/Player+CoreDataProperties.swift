//
//  Player+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 10.10.16.
//
//

import Foundation
import CoreData

extension Player {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player");
    }

    @NSManaged public var birth: NSDate?
    @NSManaged public var firstNameEn: String?
    @NSManaged public var firstNameRu: String?
    @NSManaged public var gender: NSNumber?
    @NSManaged public var height: NSNumber?
    @NSManaged public var lastNameEn: String?
    @NSManaged public var lastNameRu: String?
    @NSManaged public var objectId: NSNumber?
    @NSManaged public var playerNumber: NSNumber?
    @NSManaged public var positionEn: String?
    @NSManaged public var positionRu: String?
    @NSManaged public var positionShortEn: String?
    @NSManaged public var positionShortRu: String?
    @NSManaged public var weight: NSNumber?
    @NSManaged public var gameStatistics: NSSet?
    @NSManaged public var ranks: NSSet?
    @NSManaged public var seasonTeams: NSSet?
    @NSManaged public var team: Team?
    @NSManaged public var teamStatistics: TeamStatistics?
    @NSManaged public var playerStatistics: NSSet?

}

// MARK: Generated accessors for gameStatistics
extension Player {

    @objc(addGameStatisticsObject:)
    @NSManaged public func addToGameStatistics(_ value: GameStatistics)

    @objc(removeGameStatisticsObject:)
    @NSManaged public func removeFromGameStatistics(_ value: GameStatistics)

    @objc(addGameStatistics:)
    @NSManaged public func addToGameStatistics(_ values: NSSet)

    @objc(removeGameStatistics:)
    @NSManaged public func removeFromGameStatistics(_ values: NSSet)

}

// MARK: Generated accessors for ranks
extension Player {

    @objc(addRanksObject:)
    @NSManaged public func addToRanks(_ value: PlayerRank)

    @objc(removeRanksObject:)
    @NSManaged public func removeFromRanks(_ value: PlayerRank)

    @objc(addRanks:)
    @NSManaged public func addToRanks(_ values: NSSet)

    @objc(removeRanks:)
    @NSManaged public func removeFromRanks(_ values: NSSet)

}

// MARK: Generated accessors for seasonTeams
extension Player {

    @objc(addSeasonTeamsObject:)
    @NSManaged public func addToSeasonTeams(_ value: SeasonTeam)

    @objc(removeSeasonTeamsObject:)
    @NSManaged public func removeFromSeasonTeams(_ value: SeasonTeam)

    @objc(addSeasonTeams:)
    @NSManaged public func addToSeasonTeams(_ values: NSSet)

    @objc(removeSeasonTeams:)
    @NSManaged public func removeFromSeasonTeams(_ values: NSSet)

}

// MARK: Generated accessors for playerStatistics
extension Player {

    @objc(addPlayerStatisticsObject:)
    @NSManaged public func addToPlayerStatistics(_ value: GameStatistics)

    @objc(removePlayerStatisticsObject:)
    @NSManaged public func removeFromPlayerStatistics(_ value: GameStatistics)

    @objc(addPlayerStatistics:)
    @NSManaged public func addToPlayerStatistics(_ values: NSSet)

    @objc(removePlayerStatistics:)
    @NSManaged public func removeFromPlayerStatistics(_ values: NSSet)

}
