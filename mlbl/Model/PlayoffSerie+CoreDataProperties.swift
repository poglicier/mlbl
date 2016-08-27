//
//  PlayoffSerie+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 27.08.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PlayoffSerie {

    @NSManaged var round: NSNumber?
    @NSManaged var sort: NSNumber?
    @NSManaged var score1: NSNumber?
    @NSManaged var score2: NSNumber?
    @NSManaged var roundNameRu: String?
    @NSManaged var roundNameEn: String?
    @NSManaged var sectionSort: NSNumber?
    @NSManaged var games: NSSet?
    @NSManaged var team1: Team?
    @NSManaged var team2: Team?
    @NSManaged var competition: Competition?

}
