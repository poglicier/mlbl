//
//  StatParameter+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 10.10.16.
//
//

import Foundation
import CoreData

extension StatParameter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StatParameter> {
        return NSFetchRequest<StatParameter>(entityName: "StatParameter");
    }

    @NSManaged public var name: String?
    @NSManaged public var objectId: NSNumber?
    @NSManaged public var ranks: NSSet?

}

// MARK: Generated accessors for ranks
extension StatParameter {

    @objc(addRanksObject:)
    @NSManaged public func addToRanks(_ value: PlayerRank)

    @objc(removeRanksObject:)
    @NSManaged public func removeFromRanks(_ value: PlayerRank)

    @objc(addRanks:)
    @NSManaged public func addToRanks(_ values: NSSet)

    @objc(removeRanks:)
    @NSManaged public func removeFromRanks(_ values: NSSet)

}
