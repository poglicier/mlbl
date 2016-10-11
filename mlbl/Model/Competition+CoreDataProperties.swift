//
//  Competition+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 11.10.16.
//
//

import Foundation
import CoreData

extension Competition {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Competition> {
        return NSFetchRequest<Competition>(entityName: "Competition");
    }

    @NSManaged public var compAbcNameEn: String?
    @NSManaged public var compAbcNameRu: String?
    @NSManaged public var compShortNameEn: String?
    @NSManaged public var compShortNameRu: String?
    @NSManaged public var compType: NSNumber?
    @NSManaged public var isChoosen: NSNumber?
    @NSManaged public var objectId: NSNumber?
    @NSManaged public var children: NSSet?
    @NSManaged public var parent: Competition?
    @NSManaged public var playoffSeries: NSSet?
    @NSManaged public var roundRanks: NSSet?

}

// MARK: Generated accessors for children
extension Competition {

    @objc(addChildrenObject:)
    @NSManaged public func addToChildren(_ value: Competition)

    @objc(removeChildrenObject:)
    @NSManaged public func removeFromChildren(_ value: Competition)

    @objc(addChildren:)
    @NSManaged public func addToChildren(_ values: NSSet)

    @objc(removeChildren:)
    @NSManaged public func removeFromChildren(_ values: NSSet)

}

// MARK: Generated accessors for playoffSeries
extension Competition {

    @objc(addPlayoffSeriesObject:)
    @NSManaged public func addToPlayoffSeries(_ value: PlayoffSerie)

    @objc(removePlayoffSeriesObject:)
    @NSManaged public func removeFromPlayoffSeries(_ value: PlayoffSerie)

    @objc(addPlayoffSeries:)
    @NSManaged public func addToPlayoffSeries(_ values: NSSet)

    @objc(removePlayoffSeries:)
    @NSManaged public func removeFromPlayoffSeries(_ values: NSSet)

}

// MARK: Generated accessors for roundRanks
extension Competition {

    @objc(addRoundRanksObject:)
    @NSManaged public func addToRoundRanks(_ value: TeamRoundRank)

    @objc(removeRoundRanksObject:)
    @NSManaged public func removeFromRoundRanks(_ value: TeamRoundRank)

    @objc(addRoundRanks:)
    @NSManaged public func addToRoundRanks(_ values: NSSet)

    @objc(removeRoundRanks:)
    @NSManaged public func removeFromRoundRanks(_ values: NSSet)

}
