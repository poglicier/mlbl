//
//  Competition.swift
//  
//
//  Created by Valentin Shamardin on 20.07.16.
//
//

import Foundation
import CoreData


public class Competition: NSManagedObject {

    static fileprivate let objectIdKey = "CompID"
    static fileprivate let compShortNameRuKey = "CompShortNameRu"
    static fileprivate let compShortNameEnKey = "CompShortNameEn"
    static fileprivate let compAbcNameRu = "CompAbcNameRu"
    static fileprivate let compAbcNameEn = "CompAbcNameEn"
    static fileprivate let compTypeKey = "CompType"
    static fileprivate let childrenKey = "Children"
    
    @discardableResult
    static func compWithDict(_ dict: [String:AnyObject], inContext context: NSManagedObjectContext) -> Competition? {
        var res: Competition?
        
        if let objectId = dict[objectIdKey] as? NSNumber {
            let fetchRequest = NSFetchRequest<Competition>(entityName: Competition.entityName())
            fetchRequest.predicate = NSPredicate(format: "objectId = %@", objectId)
            do {
                res = try context.fetch(fetchRequest).first
                
                if res == nil {
                    res = Competition(entity: NSEntityDescription.entity(forEntityName: Competition.entityName(), in: context)!, insertInto: context)
                    res?.objectId = objectId
                }
                
                res?.compShortNameRu = dict[compShortNameRuKey] as? String
                res?.compShortNameEn = dict[compShortNameEnKey] as? String
                res?.compAbcNameRu = dict[compAbcNameRu] as? String
                res?.compAbcNameEn = dict[compAbcNameEn] as? String
                res?.compType = dict[compTypeKey] as? Int as NSNumber?
                
                var childIdsToSave = [NSNumber]()
                if let children = dict[childrenKey] as? [[String:AnyObject]] {
                    for childDict in children {
                        if let child = Competition.compWithDict(childDict, inContext: context) {
                            child.parent = res
                            
                            if let compId = child.objectId {
                                childIdsToSave.append(compId)
                            }
                        }
                    }
                    
                    // Удаляем из Core Data турниры
                    let fetchRequest = NSFetchRequest<Competition>(entityName: Competition.entityName())
                    fetchRequest.predicate = NSPredicate(format: "parent.objectId = %@", res!.objectId!)
                    
                    do {
                        let all = try context.fetch(fetchRequest)
                        for comp in all {
                            if let compId = comp.objectId {
                                if childIdsToSave.contains(compId) == false {
                                    print("DELETE COMPETITION \(comp.compAbcNameRu)-\(comp.compShortNameRu)")
                                    context.delete(comp)
                                }
                            }
                        }
                    }
                    catch {}
                }
                
            } catch {}
        }
        
        return res
    }
    
    fileprivate func compTypeStr() -> String {
        switch self.compType?.intValue ?? 0 {
        case 0:
            return "Группа"
        case 1, 2, 3, 5, 7:
            return "Раунд плей-офф"
        case 4, 8, 10:
            return "Плей-офф"
        default:
            return "Неизвестна"
        }
    }
    
    override public var description: String {
        get {
            return String(format: "%@ <\(Unmanaged.passUnretained(self).toOpaque())> \(self.objectId) \(self.compShortNameRu ?? "") Стадия: \(compTypeStr())", type(of: self).description())
        }
    }
}
