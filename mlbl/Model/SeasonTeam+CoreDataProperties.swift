//
//  SeasonTeam+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 10.10.16.
//
//

import Foundation
import CoreData

extension SeasonTeam {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SeasonTeam> {
        return NSFetchRequest<SeasonTeam>(entityName: "SeasonTeam");
    }

    @NSManaged public var abcNameEn: String?
    @NSManaged public var abcNameRu: String?
    @NSManaged public var nameEn: String?
    @NSManaged public var nameRu: String?
    @NSManaged public var player: Player?
    @NSManaged public var team: Team?

}
