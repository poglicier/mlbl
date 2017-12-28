//
//  Team+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 29.12.2017.
//
//

import Foundation
import CoreData


extension Team {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Team> {
        return NSFetchRequest<Team>(entityName: "Team")
    }

    @NSManaged public var nameEn: String?
    @NSManaged public var nameRu: String?
    @NSManaged public var objectId: NSNumber?
    @NSManaged public var regionNameEn: String?
    @NSManaged public var regionNameRu: String?
    @NSManaged public var shortNameEn: String?
    @NSManaged public var shortNameRu: String?
    @NSManaged public var subscribed: NSNumber?
    @NSManaged public var gameStatistics: NSSet?
    @NSManaged public var players: NSSet?
    @NSManaged public var playerStatisticsA: NSSet?
    @NSManaged public var playerStatisticsB: NSSet?
    @NSManaged public var playoffSeries1: NSSet?
    @NSManaged public var playoffSeries2: NSSet?
    @NSManaged public var roundRanks: NSSet?
    @NSManaged public var seasonTeams: NSSet?
    @NSManaged public var teamStatistics: NSSet?

}

// MARK: Generated accessors for gameStatistics
extension Team {

    @objc(addGameStatisticsObject:)
    @NSManaged public func addToGameStatistics(_ value: GameStatistics)

    @objc(removeGameStatisticsObject:)
    @NSManaged public func removeFromGameStatistics(_ value: GameStatistics)

    @objc(addGameStatistics:)
    @NSManaged public func addToGameStatistics(_ values: NSSet)

    @objc(removeGameStatistics:)
    @NSManaged public func removeFromGameStatistics(_ values: NSSet)

}

// MARK: Generated accessors for players
extension Team {

    @objc(addPlayersObject:)
    @NSManaged public func addToPlayers(_ value: Player)

    @objc(removePlayersObject:)
    @NSManaged public func removeFromPlayers(_ value: Player)

    @objc(addPlayers:)
    @NSManaged public func addToPlayers(_ values: NSSet)

    @objc(removePlayers:)
    @NSManaged public func removeFromPlayers(_ values: NSSet)

}

// MARK: Generated accessors for playerStatisticsA
extension Team {

    @objc(addPlayerStatisticsAObject:)
    @NSManaged public func addToPlayerStatisticsA(_ value: PlayerStatistics)

    @objc(removePlayerStatisticsAObject:)
    @NSManaged public func removeFromPlayerStatisticsA(_ value: PlayerStatistics)

    @objc(addPlayerStatisticsA:)
    @NSManaged public func addToPlayerStatisticsA(_ values: NSSet)

    @objc(removePlayerStatisticsA:)
    @NSManaged public func removeFromPlayerStatisticsA(_ values: NSSet)

}

// MARK: Generated accessors for playerStatisticsB
extension Team {

    @objc(addPlayerStatisticsBObject:)
    @NSManaged public func addToPlayerStatisticsB(_ value: PlayerStatistics)

    @objc(removePlayerStatisticsBObject:)
    @NSManaged public func removeFromPlayerStatisticsB(_ value: PlayerStatistics)

    @objc(addPlayerStatisticsB:)
    @NSManaged public func addToPlayerStatisticsB(_ values: NSSet)

    @objc(removePlayerStatisticsB:)
    @NSManaged public func removeFromPlayerStatisticsB(_ values: NSSet)

}

// MARK: Generated accessors for playoffSeries1
extension Team {

    @objc(addPlayoffSeries1Object:)
    @NSManaged public func addToPlayoffSeries1(_ value: PlayoffSerie)

    @objc(removePlayoffSeries1Object:)
    @NSManaged public func removeFromPlayoffSeries1(_ value: PlayoffSerie)

    @objc(addPlayoffSeries1:)
    @NSManaged public func addToPlayoffSeries1(_ values: NSSet)

    @objc(removePlayoffSeries1:)
    @NSManaged public func removeFromPlayoffSeries1(_ values: NSSet)

}

// MARK: Generated accessors for playoffSeries2
extension Team {

    @objc(addPlayoffSeries2Object:)
    @NSManaged public func addToPlayoffSeries2(_ value: PlayoffSerie)

    @objc(removePlayoffSeries2Object:)
    @NSManaged public func removeFromPlayoffSeries2(_ value: PlayoffSerie)

    @objc(addPlayoffSeries2:)
    @NSManaged public func addToPlayoffSeries2(_ values: NSSet)

    @objc(removePlayoffSeries2:)
    @NSManaged public func removeFromPlayoffSeries2(_ values: NSSet)

}

// MARK: Generated accessors for roundRanks
extension Team {

    @objc(addRoundRanksObject:)
    @NSManaged public func addToRoundRanks(_ value: TeamRoundRank)

    @objc(removeRoundRanksObject:)
    @NSManaged public func removeFromRoundRanks(_ value: TeamRoundRank)

    @objc(addRoundRanks:)
    @NSManaged public func addToRoundRanks(_ values: NSSet)

    @objc(removeRoundRanks:)
    @NSManaged public func removeFromRoundRanks(_ values: NSSet)

}

// MARK: Generated accessors for seasonTeams
extension Team {

    @objc(addSeasonTeamsObject:)
    @NSManaged public func addToSeasonTeams(_ value: SeasonTeam)

    @objc(removeSeasonTeamsObject:)
    @NSManaged public func removeFromSeasonTeams(_ value: SeasonTeam)

    @objc(addSeasonTeams:)
    @NSManaged public func addToSeasonTeams(_ values: NSSet)

    @objc(removeSeasonTeams:)
    @NSManaged public func removeFromSeasonTeams(_ values: NSSet)

}

// MARK: Generated accessors for teamStatistics
extension Team {

    @objc(addTeamStatisticsObject:)
    @NSManaged public func addToTeamStatistics(_ value: TeamStatistics)

    @objc(removeTeamStatisticsObject:)
    @NSManaged public func removeFromTeamStatistics(_ value: TeamStatistics)

    @objc(addTeamStatistics:)
    @NSManaged public func addToTeamStatistics(_ values: NSSet)

    @objc(removeTeamStatistics:)
    @NSManaged public func removeFromTeamStatistics(_ values: NSSet)

}
