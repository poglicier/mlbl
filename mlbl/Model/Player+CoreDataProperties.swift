//
//  Player+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 19.07.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Player {

    @NSManaged var objectId: NSNumber?
    @NSManaged var lastNameRu: String?
    @NSManaged var firstNameRu: String?
    @NSManaged var firstNameEn: String?
    @NSManaged var lastNameEn: String?
    @NSManaged var birth: NSDate?
    @NSManaged var height: NSNumber?
    @NSManaged var weight: NSNumber?
    @NSManaged var gender: NSNumber?
    @NSManaged var team: Team?

}
