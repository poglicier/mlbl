//
//  StatParameter.swift
//  
//
//  Created by Valentin Shamardin on 10.08.16.
//
//

import Foundation
import CoreData


public class StatParameter: NSManagedObject {

    static let StatParameterIdKey = "param"
    static let StatParameterNameKey = "name"
    
    @discardableResult
    static func parameterWithDict(_ dict: [String:AnyObject], inContext context: NSManagedObjectContext) -> StatParameter? {
        var res: StatParameter?
        
        if let objectId = dict[StatParameterIdKey] as? NSNumber {
            let fetchRequest = NSFetchRequest<StatParameter>(entityName: StatParameter.entityName())
            fetchRequest.predicate = NSPredicate(format: "objectId = %@", objectId)
            do {
                res = try context.fetch(fetchRequest).first
                
                if res == nil {
                    res = StatParameter(entity: NSEntityDescription.entity(forEntityName: StatParameter.entityName(), in: context)!, insertInto: context)
                    res?.objectId = objectId
                }
            } catch {}
            
            res?.name = dict[StatParameterNameKey] as? String
        }
        
        return res
    }
}
