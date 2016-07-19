//
//  Region+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 18.07.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Region {

    @NSManaged var isChoosen: NSNumber?
    @NSManaged var nameEn: String?
    @NSManaged var nameRu: String?
    @NSManaged var objectId: NSNumber?
    @NSManaged var nameRuOrder: NSNumber?
    @NSManaged var nameEnOrder: NSNumber?

}
