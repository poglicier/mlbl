//
//  Game.swift
//  
//
//  Created by Valentin Shamardin on 05.03.16.
//
//

import Foundation
import CoreData


class Game: NSManagedObject {
    private enum Keys: String {
        case GameId = "GameID"
        case GameDate = "GameDate"
        case GameTime = "GameTime"
        case GameNumber = "GameNumber"
        case VenueRu = "VenueRu"
        case VenueEn = "VenueEn"
        case Score = "Score"
        case ScoreByPeriods = "ScoreByPeriods"
        case TeamA = "TeamA"
        case TeamB = "TeamB"
    }
    static func gameWithDict(dict: [String:AnyObject], inContext context: NSManagedObjectContext) -> Game? {
        var res: Game?
        
        print(dict)
        if let objectId = dict[Keys.GameId.rawValue] as? NSNumber {
            let fetchRequest = NSFetchRequest(entityName: Game.entityName())
            fetchRequest.predicate = NSPredicate(format: "objectId = %@", objectId)
            do {
                res = try context.executeFetchRequest(fetchRequest).first as? Game
                
                if res == nil {
                    res = Game.init(entity: NSEntityDescription.entityForName(Game.entityName(), inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
                    res?.objectId = objectId
                }
                
                res?.venueEn = dict[Keys.VenueEn.rawValue] as? String
                res?.venueRu = dict[Keys.VenueRu.rawValue] as? String
                res?.scoreByPeriods = dict[Keys.ScoreByPeriods.rawValue] as? String
                
                if let teamA = dict[Keys.TeamA.rawValue] as? [String:AnyObject] {
                    res?.scoreA = teamA[Keys.Score.rawValue] as? NSNumber
                }
                
                if let teamB = dict[Keys.TeamB.rawValue] as? [String:AnyObject] {
                    res?.scoreB = teamB[Keys.Score.rawValue] as? NSNumber
                }
                
                if let dateString = dict[Keys.GameDate.rawValue] as? String {
                    if let timeString = dict[Keys.GameTime.rawValue] as? String {
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "dd.MM.yyyy hh:mm"
                        res?.date = dateFormatter.dateFromString("\(dateString) \(timeString)")
                    }
                }
            } catch {}
        }
        
        return res
    }
}