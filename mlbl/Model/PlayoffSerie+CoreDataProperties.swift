//
//  PlayoffSerie+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 10.10.16.
//
//

import Foundation
import CoreData

extension PlayoffSerie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlayoffSerie> {
        return NSFetchRequest<PlayoffSerie>(entityName: "PlayoffSerie");
    }

    @NSManaged public var round: NSNumber?
    @NSManaged public var roundNameEn: String?
    @NSManaged public var roundNameRu: String?
    @NSManaged public var score1: NSNumber?
    @NSManaged public var score2: NSNumber?
    @NSManaged public var sectionSort: NSNumber?
    @NSManaged public var sort: NSNumber?
    @NSManaged public var competition: Competition?
    @NSManaged public var games: NSSet?
    @NSManaged public var team1: Team?
    @NSManaged public var team2: Team?

}

// MARK: Generated accessors for games
extension PlayoffSerie {

    @objc(addGamesObject:)
    @NSManaged public func addToGames(_ value: Game)

    @objc(removeGamesObject:)
    @NSManaged public func removeFromGames(_ value: Game)

    @objc(addGames:)
    @NSManaged public func addToGames(_ values: NSSet)

    @objc(removeGames:)
    @NSManaged public func removeFromGames(_ values: NSSet)

}
