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
                
                if let nameRu = res?.nameRu {
                    switch nameRu {
                    case "Москва":
                        res?.nameRuOrder = NSNumber(int: 1)
                    case "Санкт-Петербург":
                        res?.nameRuOrder = NSNumber(int: 2)
                    default:
                        res?.nameRuOrder = NSNumber(int: 3)
                    }
                } else {
                    res?.nameRuOrder = NSNumber(int: 3)
                }
                
                if let nameEn = res?.nameEn {
                    switch nameEn {
                    case "Moscow":
                        res?.nameEnOrder = NSNumber(int: 1)
                    case "Saint-Petersburg":
                        res?.nameEnOrder = NSNumber(int: 2)
                    default:
                        res?.nameEnOrder = NSNumber(int: 3)
                    }
                } else {
                    res?.nameEnOrder = NSNumber(int: 3)
                }
            } catch {}
        }
        
        return res
    }
}