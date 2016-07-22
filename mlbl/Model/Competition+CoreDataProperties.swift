//
//  Competition+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 22.07.16.
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
    @NSManaged var isChoosen: NSNumber?
    @NSManaged var objectId: NSNumber?
    @NSManaged var compType: NSNumber?
    @NSManaged var children: NSSet?
    @NSManaged var parent: Competition?

}
