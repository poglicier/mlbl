//
//  PlayoffSerie.swift
//  
//
//  Created by Valentin Shamardin on 26.08.16.
//
//

import Foundation
import CoreData


class PlayoffSerie: NSManagedObject {

    static private let TeamName1Key = "TeamName1"
    static private let TeamName2Key = "TeamName2"
    static private let TeamIDKey = "TeamID"
    static private let CompTeamShortNameRuKey = "CompTeamShortNameRu"
    static private let CompTeamShortNameEnKey = "CompTeamShortNameEn"
    static private let CompTeamNameRuKey = "CompTeamNameRu"
    static private let CompTeamNameEnKey = "CompTeamNameEn"
    static private let RoundKey = "Round"
    static private let SortKey = "Sort"
    static private let Score1Key = "Score1"
    static private let Score2Key = "Score2"
    static private let ScoreKey = "Score"
    static private let ScoresKey = "Scores"
    static private let RoundNameRuKey = "RoundNameRu"
    static private let RoundNameEnKey = "RoundNameEn"
    
    static func playoffWithDict(dict: [String:AnyObject], compId: Int, inContext context: NSManagedObjectContext) -> PlayoffSerie? {
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
                        res = PlayoffSerie(entity: NSEntityDescription.entityForName(PlayoffSerie.entityName(), inManagedObjectContext: context)!, insertIntoManagedObjectContext: context)
                        
                        let parameterRequest = NSFetchRequest(entityName: Competition.entityName())
                        parameterRequest.predicate = NSPredicate(format: "objectId = %d", compId)
                        do {
                            res?.competition = (try context.executeFetchRequest(parameterRequest) as! [Competition]).first
                        } catch {
                            res = nil
                        }
                        
                        res?.team1 = team1
                        res?.team2 = team2
                        res?.round = dict[RoundKey] as? Int
                        res?.sort = dict[SortKey] as? Int
                        res?.score1 = dict[Score1Key] as? Int
                        res?.score2 = dict[Score2Key] as? Int
                        res?.roundNameEn = dict[RoundNameEnKey] as? String
                        res?.roundNameRu = dict[RoundNameRuKey] as? String
                        
                        // Игры
                        if let gamesDicts = dict[ScoresKey] as? [[String:AnyObject]] {
                            var games = Set<Game>()
                            for gameDict in gamesDicts {
                                var fixedGameDict = gameDict
                                
                                fixedGameDict[Game.TeamAIdKey] = res?.team1?.objectId
                                fixedGameDict[Game.TeamBIdKey] = res?.team2?.objectId
                                fixedGameDict[Game.TeamNameAenKey] = res?.team1?.nameEn
                                fixedGameDict[Game.TeamNameAruKey] = res?.team1?.nameRu
                                fixedGameDict[Game.ShortTeamNameAenKey] = res?.team1?.shortNameEn
                                fixedGameDict[Game.ShortTeamNameAruKey] = res?.team1?.shortNameRu
                                fixedGameDict[Game.TeamNameBenKey] = res?.team2?.nameEn
                                fixedGameDict[Game.TeamNameBruKey] = res?.team2?.nameRu
                                fixedGameDict[Game.ShortTeamNameBenKey] = res?.team2?.shortNameEn
                                fixedGameDict[Game.ShortTeamNameBruKey] = res?.team2?.shortNameRu
                                
                                if let scoresStr = (gameDict[ScoreKey] as? String)?.componentsSeparatedByString(":") {
                                    if scoresStr.count == 2 {
                                        let scoreA = Int(scoresStr.first!)
                                        let scoreB = Int(scoresStr.last!)
                                        fixedGameDict[Game.ScoreAKey] = scoreA
                                        fixedGameDict[Game.ScoreBKey] = scoreB
                                    }
                                }
                                
                                if let game = Game.gameWithDict(fixedGameDict, inContext: context) {
                                    games.insert(game)
                                }
                            }
                            res?.games = games
                        }
                    }
                }
            }
        }
        
        return res
    }
    
    override var description: String {
        get {
            return String(format: "%@ <\(unsafeAddressOf(self))> round: \(self.round) sort: \(self.sort ?? "") \(self.roundNameRu) sectionSort \(self.sectionSort)", self.dynamicType.description())
        }
    }
}