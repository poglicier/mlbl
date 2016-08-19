//
//  StatParameter.swift
//  
//
//  Created by Valentin Shamardin on 10.08.16.
//
//

import Foundation
import CoreData


class StatParameter: NSManagedObject {

    static let StatParameterIdKey = "param"
    static let StatParameterNameKey = "name"
    
    static func parameterWithDict(dict: [String:AnyObject], inContext context: NSManagedObjectContext) -> StatParameter? {
        var res: StatParameter?
        
        if let objectId = dict[StatParameterIdKey] as? NSNumber {
            let fetchRequest = NSFetchRequest(entityName: StatParameter.entityName())
            fetchRequest.predicate = NSPredicate(format: "objectId = %@", objectId)
            do {
                res = try context.executeFetchRequest(fetchRequest).first as? StatParameter
                
                if res == nil {
                    res = StatParameter(entity: NSEntityDescription.entityForName(StatParameter.entityName(), inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
                    res?.objectId = objectId
                }
            } catch {}
            
            res?.name = dict[StatParameterNameKey] as? String
        }
        
        return res
    }
}