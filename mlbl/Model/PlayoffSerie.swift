//
//  PlayoffSerie.swift
//  
//
//  Created by Valentin Shamardin on 26.08.16.
//
//

import Foundation
import CoreData


public class PlayoffSerie: NSManagedObject {

    static fileprivate let TeamName1Key = "TeamName1"
    static fileprivate let TeamName2Key = "TeamName2"
    static fileprivate let TeamIDKey = "TeamID"
    static fileprivate let CompTeamShortNameRuKey = "CompTeamShortNameRu"
    static fileprivate let CompTeamShortNameEnKey = "CompTeamShortNameEn"
    static fileprivate let CompTeamNameRuKey = "CompTeamNameRu"
    static fileprivate let CompTeamNameEnKey = "CompTeamNameEn"
    static fileprivate let RoundKey = "Round"
    static fileprivate let SortKey = "Sort"
    static fileprivate let Score1Key = "Score1"
    static fileprivate let Score2Key = "Score2"
    static fileprivate let ScoreKey = "Score"
    static fileprivate let ScoresKey = "Scores"
    static fileprivate let RoundNameRuKey = "RoundNameRu"
    static fileprivate let RoundNameEnKey = "RoundNameEn"
    
    @discardableResult
    static func playoffWithDict(_ dict: [String:AnyObject], compId: Int, inContext context: NSManagedObjectContext) -> PlayoffSerie? {
        var res: PlayoffSerie?
        
        if let team1Dict = dict[TeamName1Key] as? [String:AnyObject] {
            var teamDict = [String:AnyObject]()
            teamDict[Team.TeamIdKey] = team1Dict[TeamIDKey]
            teamDict[Team.ShortTeamNameEnKey] = team1Dict[CompTeamShortNameEnKey]
            teamDict[Team.ShortTeamNameRuKey] = team1Dict[CompTeamShortNameRuKey]
            teamDict[Team.TeamNameEnKey] = team1Dict[CompTeamNameEnKey]
            teamDict[Team.TeamNameRuKey] = team1Dict[CompTeamNameRuKey]
            
            if let team1 = Team.teamWithDict(teamDict, inContext: context) {
                if let team2Dict = dict[TeamName2Key] as? [String:AnyObject] {
                    var teamDict = [String:AnyObject]()
                    teamDict[Team.TeamIdKey] = team2Dict[TeamIDKey]
                    teamDict[Team.ShortTeamNameEnKey] = team2Dict[CompTeamShortNameEnKey]
                    teamDict[Team.ShortTeamNameRuKey] = team2Dict[CompTeamShortNameRuKey]
                    teamDict[Team.TeamNameEnKey] = team2Dict[CompTeamNameEnKey]
                    teamDict[Team.TeamNameRuKey] = team2Dict[CompTeamNameRuKey]
                    
                    if let team2 = Team.teamWithDict(teamDict, inContext: context) {
                        // Теперь проверили, все параметры на месте - можно создавать объект
                        res = PlayoffSerie(entity: NSEntityDescription.entity(forEntityName: PlayoffSerie.entityName(), in: context)!, insertInto: context)
                        
                        let parameterRequest = NSFetchRequest<Competition>(entityName: Competition.entityName())
                        parameterRequest.predicate = NSPredicate(format: "objectId = %d", compId)
                        do {
                            res?.competition = try context.fetch(parameterRequest).first
                        } catch {
                            res = nil
                        }
                        
                        res?.team1 = team1
                        res?.team2 = team2
                        res?.round = dict[RoundKey] as? Int as NSNumber?
                        res?.sort = dict[SortKey] as? Int as NSNumber?
                        res?.score1 = dict[Score1Key] as? Int as NSNumber?
                        res?.score2 = dict[Score2Key] as? Int as NSNumber?
                        res?.roundNameEn = dict[RoundNameEnKey] as? String
                        res?.roundNameRu = dict[RoundNameRuKey] as? String
                        
                        // Игры
                        if let gamesDicts = dict[ScoresKey] as? [[String:AnyObject]] {
                            var games = Set<Game>()
                            for gameDict in gamesDicts {
                                var fixedGameDict = gameDict
                                
                                fixedGameDict[Game.TeamAIdKey] = res?.team1?.objectId
                                fixedGameDict[Game.TeamBIdKey] = res?.team2?.objectId
                                fixedGameDict[Game.TeamNameAenKey] = res?.team1?.nameEn as AnyObject?
                                fixedGameDict[Game.TeamNameAruKey] = res?.team1?.nameRu as AnyObject?
                                fixedGameDict[Game.ShortTeamNameAenKey] = res?.team1?.shortNameEn as AnyObject?
                                fixedGameDict[Game.ShortTeamNameAruKey] = res?.team1?.shortNameRu as AnyObject?
                                fixedGameDict[Game.TeamNameBenKey] = res?.team2?.nameEn as AnyObject?
                                fixedGameDict[Game.TeamNameBruKey] = res?.team2?.nameRu as AnyObject?
                                fixedGameDict[Game.ShortTeamNameBenKey] = res?.team2?.shortNameEn as AnyObject?
                                fixedGameDict[Game.ShortTeamNameBruKey] = res?.team2?.shortNameRu as AnyObject?
                                
                                if let scoresStr = (gameDict[ScoreKey] as? String)?.components(separatedBy: ":") {
                                    if scoresStr.count == 2 {
                                        let scoreA = Int(scoresStr.first!)
                                        let scoreB = Int(scoresStr.last!)
                                        fixedGameDict[Game.ScoreAKey] = scoreA as AnyObject?
                                        fixedGameDict[Game.ScoreBKey] = scoreB as AnyObject?
                                    }
                                }
                                
                                if let game = Game.gameWithDict(fixedGameDict, inContext: context) {
                                    games.insert(game)
                                }
                            }
                            res?.games = games as NSSet?
                        }
                    }
                }
            }
        }
        
        return res
    }
    
    override public var description: String {
        get {
            var sortStr = ""
            if let _ = self.sort {
                sortStr = "\(self.sort!)"
            }
            return String(format: "%@ <\(Unmanaged.passUnretained(self).toOpaque())> round: \(self.round) sort: \(sortStr) \(self.roundNameRu) sectionSort \(self.sectionSort)", type(of: self).description())
        }
    }
}
