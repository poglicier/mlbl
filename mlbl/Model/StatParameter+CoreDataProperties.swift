//
//  StatParameter+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 17.08.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension StatParameter {

    @NSManaged var name: String?
    @NSManaged var objectId: NSNumber?
    @NSManaged var ranks: NSSet?

}
