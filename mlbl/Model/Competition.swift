//
//  Competition.swift
//  
//
//  Created by Valentin Shamardin on 20.07.16.
//
//

import Foundation
import CoreData


class Competition: NSManagedObject {

    static private let objectIdKey = "CompID"
    static private let compShortNameRuKey = "CompShortNameRu"
    static private let compShortNameEnKey = "CompShortNameEn"
    static private let compAbcNameRu = "CompAbcNameRu"
    static private let compAbcNameEn = "CompAbcNameEn"
    static private let compSortKey = "CompSort"
    static private let compTypeKey = "CompType"
    static private let childrenKey = "Children"
    
    static func compWithDict(dict: [String:AnyObject], inContext context: NSManagedObjectContext) -> Competition? {
        var res: Competition?
        
        if let objectId = dict[objectIdKey] as? NSNumber {
            let fetchRequest = NSFetchRequest(entityName: Competition.entityName())
            fetchRequest.predicate = NSPredicate(format: "objectId = %@", objectId)
            do {
                res = try context.executeFetchRequest(fetchRequest).first as? Competition
                
                if res == nil {
                    res = Competition(entity: NSEntityDescription.entityForName(Competition.entityName(), inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
                    res?.objectId = objectId
                }
                
                res?.compShortNameRu = dict[compShortNameRuKey] as? String
                res?.compShortNameEn = dict[compShortNameEnKey] as? String
                res?.compAbcNameRu = dict[compAbcNameRu] as? String
                res?.compAbcNameEn = dict[compAbcNameEn] as? String
                res?.compSort = dict[compSortKey] as? Int
                res?.compType = dict[compTypeKey] as? Int
                
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
                    let fetchRequest = NSFetchRequest(entityName: Competition.entityName())
                    fetchRequest.predicate = NSPredicate(format: "parent.objectId = %@", res!.objectId!)
                    
                    do {
                        let all = try context.executeFetchRequest(fetchRequest) as! [Competition]
                        for comp in all {
                            if let compId = comp.objectId {
                                if childIdsToSave.contains(compId) == false {
                                    print("DELETE COMPETITION \(comp.compAbcNameRu)-\(comp.compShortNameRu)")
                                    context.deleteObject(comp)
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
    
    private func compTypeStr() -> String {
        switch self.compType?.integerValue ?? 0 {
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
    
    override var description: String {
        get {
            return String(format: "%@ <\(unsafeAddressOf(self))> \(self.objectId) \(self.compShortNameRu ?? "") Стадия: \(compTypeStr())", self.dynamicType.description())
        }
    }
}