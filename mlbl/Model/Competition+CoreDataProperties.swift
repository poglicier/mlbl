//
//  Competition+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 26.08.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Competition {

    @NSManaged var compAbcNameEn: String?
    @NSManaged var compAbcNameRu: String?
    @NSManaged var compShortNameEn: String?
    @NSManaged var compShortNameRu: String?
    @NSManaged var compSort: NSNumber?
    @NSManaged var compType: NSNumber?
    @NSManaged var isChoosen: NSNumber?
    @NSManaged var objectId: NSNumber?
    @NSManaged var children: NSSet?
    @NSManaged var parent: Competition?
    @NSManaged var roundRanks: NSSet?
    @NSManaged var playoffSeries: NSSet?

}
