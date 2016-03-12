//
//  Region+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 12.03.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Region {

    @NSManaged var objectId: NSNumber?
    @NSManaged var nameRu: String?
    @NSManaged var nameEn: String?
    @NSManaged var isChoosen: NSNumber?

}
