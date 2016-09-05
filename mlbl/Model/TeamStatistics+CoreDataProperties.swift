//
//  TeamStatistics+CoreDataProperties.swift
//  
//
//  Created by Valentin Shamardin on 05.09.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TeamStatistics {

    @NSManaged var assists: NSNumber?
    @NSManaged var blocks: NSNumber?
    @NSManaged var defensiveRebounds: NSNumber?
    @NSManaged var fouls: NSNumber?
    @NSManaged var games: NSNumber?
    @NSManaged var goal1: NSNumber?
    @NSManaged var goal2: NSNumber?
    @NSManaged var goal3: NSNumber?
    @NSManaged var offensiveRebounds: NSNumber?
    @NSManaged var opponentFouls: NSNumber?
    @NSManaged var playerNumber: NSNumber?
    @NSManaged var plusMinus: NSNumber?
    @NSManaged var points: NSNumber?
    @NSManaged var seconds: NSNumber?
    @NSManaged var shot1: NSNumber?
    @NSManaged var shot2: NSNumber?
    @NSManaged var shot3: NSNumber?
    @NSManaged var steals: NSNumber?
    @NSManaged var teamNumber: NSNumber?
    @NSManaged var turnovers: NSNumber?
    @NSManaged var teamOffensiveRebounds: NSNumber?
    @NSManaged var teamDefensiveRebounds: NSNumber?
    @NSManaged var player: Player?
    @NSManaged var team: Team?

}
