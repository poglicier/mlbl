//
//  Region.swift
//  
//
//  Created by Valentin Shamardin on 12.03.16.
//
//

import Foundation
import CoreData


class Region: NSManagedObject {
    private enum Keys: String {
        case RegionId = "RegionID"
        case NameRu = "RegionNameRu"
        case NameEn = "RegionNameEn"
    }
    
    static func regionWithDict(dict: [String:AnyObject], inContext context: NSManagedObjectContext) -> Region? {
        var res: Region?
        
        if let objectId = dict[Keys.RegionId.rawValue] as? NSNumber {
            let fetchRequest = NSFetchRequest(entityName: Region.entityName())
            fetchRequest.predicate = NSPredicate(format: "objectId = %@", objectId)
            do {
                res = try context.executeFetchRequest(fetchRequest).first as? Region
                
                if res == nil {
                    res = Region.init(entity: NSEntityDescription.entityForName(Region.entityName(), inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
                    res?.objectId = objectId
                }
                
                res?.nameEn = dict[Keys.NameEn.rawValue] as? String
                res?.nameRu = dict[Keys.NameRu.rawValue] as? String
            } catch {}
        }
        
        return res
    }
}
