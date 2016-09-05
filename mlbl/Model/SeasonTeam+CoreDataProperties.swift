//
//  SeasonTeam+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 05.09.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension SeasonTeam {

    @NSManaged var nameRu: String?
    @NSManaged var nameEn: String?
    @NSManaged var abcNameRu: String?
    @NSManaged var abcNameEn: String?
    @NSManaged var team: Team?
    @NSManaged var player: Player?

}
