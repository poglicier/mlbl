//
//  StatisticCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 09.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

protocol StatisticCellDelegate: class {
    func cell(_ cell: StatisticCell, didScrollTo contentOffset: CGPoint, tag: Int)
}

class StatisticCell: UITableViewCell {
    
    @IBOutlet fileprivate var numberLabel: UILabel!
    @IBOutlet fileprivate var playerLabel: UILabel!
    @IBOutlet fileprivate var timeLabel: UILabel!
    @IBOutlet fileprivate var pointsLabel: UILabel!
    @IBOutlet fileprivate var twoLabel: UILabel!
    @IBOutlet fileprivate var threeLabel: UILabel!
    @IBOutlet fileprivate var oneLabel: UILabel!
    @IBOutlet fileprivate var reboundsOLabel: UILabel!
    @IBOutlet fileprivate var reboundsDLabel: UILabel!
    @IBOutlet fileprivate var reboundsLabel: UILabel!
    @IBOutlet fileprivate var assistsLabel: UILabel!
    @IBOutlet fileprivate var stealsLabel: UILabel!
    @IBOutlet fileprivate var turnoversLabel: UILabel!
    @IBOutlet fileprivate var blocksLabel: UILabel!
    @IBOutlet fileprivate var foulsLabel: UILabel!
    @IBOutlet fileprivate var earnedFoulsLabel: UILabel!
    @IBOutlet fileprivate var plusMinusLabel: UILabel!
    @IBOutlet fileprivate var scrollContentView: UIView!
    @IBOutlet fileprivate var background: UIView!
    @IBOutlet fileprivate var scrollView: UIScrollView!
    @IBOutlet fileprivate var twoPercentLabel: UILabel!
    @IBOutlet fileprivate var threePercentLabel: UILabel!
    @IBOutlet fileprivate var onePercentLabel: UILabel!
    @IBOutlet fileprivate var teamReboundsOLabel: UILabel!
    @IBOutlet fileprivate var teamReboundsDLabel: UILabel!
    @IBOutlet fileprivate var teamReboundsLabel: UILabel!
    @IBOutlet fileprivate var teamReboundsHeight: NSLayoutConstraint!
    @IBOutlet fileprivate var teamLabel: UILabel!
    @IBOutlet fileprivate var totalBackground: UIView!

    weak var delegate: StatisticCellDelegate?
    var language: String!
    var total = ""
    var color: UIColor? {
        didSet {
            self.background.backgroundColor = color
        }
    }
    var contentOffset: CGPoint! {
        didSet {
            self.scrollView.contentOffset = contentOffset
        }
    }
    var statistics: TeamStatistics! {
        didSet {
            self.teamReboundsHeight.constant = 0
            self.teamReboundsLabel.text = nil
            self.teamReboundsDLabel.text = nil
            self.teamReboundsOLabel.text = nil
            
            if statistics.player == nil {
                if #available(iOS 8.2, *) {
                    self.playerLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
                    for subview in self.scrollContentView.subviews {
                        if let label = subview as? UILabel {
                            if label != self.onePercentLabel &&
                                label != self.twoPercentLabel &&
                                label != self.threePercentLabel {
                                label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
                            }
                        }
                    }
                }
                
                self.totalBackground.isHidden = false
                // Когда рассматривается статистика команды, интересны только
                // проценты бросков. Средние значения обрабатываются
                // аналогично статистике игрока
                self.numberLabel.text = nil
                self.playerLabel.text = self.total
                
                self.twoPercentLabel.text = "0"
                if let goal2 = statistics.goal2?.doubleValue {
                    if let shot2 = statistics.shot2?.doubleValue {
                        if shot2 > 0 {
                            self.twoPercentLabel.text = String(format: "%.1f%%", 100*goal2/shot2)
                        }
                    }
                }
                
                self.threePercentLabel.text = "0"
                if let goal3 = statistics.goal3?.doubleValue {
                    if let shot3 = statistics.shot3?.doubleValue {
                        if shot3 > 0 {
                            self.threePercentLabel.text = String(format: "%.1f%%", 100*goal3/shot3)
                        }
                    }
                }
                
                self.onePercentLabel.text = "0"
                if let goal1 = statistics.goal1?.doubleValue {
                    if let shot1 = statistics.shot1?.doubleValue {
                        if shot1 > 0 {
                            self.onePercentLabel.text = String(format: "%.1f%%", 100*goal1/shot1)
                        }
                    }
                }
            } else {
                self.onePercentLabel.text = nil
                self.threePercentLabel.text = nil
                self.threePercentLabel.text = nil
                
                self.playerLabel.font = UIFont.systemFont(ofSize: 15)
                for subview in self.scrollContentView.subviews {
                    if let label = subview as? UILabel {
                        label.font = UIFont.systemFont(ofSize: 15)
                    }
                }
                
                self.totalBackground.isHidden = true
                
                if let playerNumber = statistics.playerNumber {
                    if playerNumber.intValue == 1000 {
                        self.numberLabel.text = NSLocalizedString("Coach acronym", comment: "")
                    } else {
                        self.numberLabel.text = "\(playerNumber)"
                    }
                }
                
                let isLanguageRu = self.language.contains("ru")
                
                self.playerLabel.lineBreakMode = .byClipping
                if var playerName = isLanguageRu ? statistics.player?.lastNameRu : statistics.player?.lastNameEn {
                    if let firstName = isLanguageRu ? statistics.player?.firstNameRu : statistics.player?.firstNameEn {
                        if firstName.count > 0 {
                            let indexOfFirst = firstName.index(firstName.startIndex, offsetBy: 1)
                            let firstLetter = firstName[..<indexOfFirst]
                            playerName += " \(firstLetter)."
                        }
                    }
                    
                    self.playerLabel.text = "\(playerName)"
                } else {
                    self.playerLabel.text = nil
                }
            }
        
            // Статистика или для команды, или для игрока
            self.timeLabel.text = nil
            if let seconds = statistics.seconds as? Int {
                if seconds > 0 {
                    let mins = seconds/60
                    let secs = seconds%60
                    self.timeLabel.text = String(format: "\(mins):%02zd", secs)
                }
            }
            
            self.pointsLabel.text = nil
            if let pts = statistics.points as? Float {
                if pts > 0 {
                    self.pointsLabel.text = String(format: "%g", pts)
                }
            }
            
            self.twoLabel.text = nil
            if let shot = statistics.shot2 as? Float {
                if shot > 0 {
                    if let goal = statistics.goal2 as? Float  {
                        self.twoLabel.text = String(format: "%g/%g", goal, shot)
                    } else {
                        self.twoLabel.text = String(format: "0/%g", shot)
                    }
                }
            }
            
            self.threeLabel.text = nil
            if let shot = statistics.shot3 as? Float {
                if shot > 0 {
                    if let goal = statistics.goal3 as? Float  {
                        threeLabel.text = String(format: "%g/%g", goal, shot)
                    } else {
                        threeLabel.text = String(format: "0/%g", shot)
                    }
                }
            }
            
            self.oneLabel.text = nil
            if let shot = statistics.shot1 as? Float {
                if shot > 0 {
                    if let goal = statistics.goal1 as? Float {
                        self.oneLabel.text = String(format: "%g/%g", goal, shot)
                    } else {
                        self.oneLabel.text = String(format: "0/%g", shot)
                    }
                }
            }
            
            self.reboundsOLabel.text = nil
            let offs = statistics.offensiveRebounds as? Float ?? 0
            if offs > 0 {
                self.reboundsOLabel.text = String(format: "%g", offs)
            }
            
            self.reboundsDLabel.text = nil
            let defs = statistics.defensiveRebounds as? Float ?? 0
            if defs > 0 {
                self.reboundsDLabel.text = String(format: "%g", defs)
            }
            
            self.reboundsLabel.text = nil
            if offs + defs > 0 {
                self.reboundsLabel.text = String(format: "%g", offs + defs)
            }
            
            self.assistsLabel.text = nil
            if let assists = statistics.assists as? Float {
                if assists > 0 {
                    assistsLabel.text = String(format: "%g", assists)
                }
            }
            
            self.stealsLabel.text = nil
            if let steals = statistics.steals as? Float {
                if steals > 0 {
                    self.stealsLabel.text = String(format: "%g", steals)
                }
            }
           
            self.turnoversLabel.text = nil
            if let turnovers = statistics.turnovers as? Float {
                if turnovers > 0 {
                    self.turnoversLabel.text = String(format: "%g", turnovers)
                }
            }
          
            self.blocksLabel.text = nil
            if let blocks = statistics.blocks as? Float {
                if blocks > 0 {
                    self.blocksLabel.text = String(format: "%g", blocks)
                }
            }
            
            self.foulsLabel.text = nil
            if let fouls = statistics.fouls as? Float {
                if fouls > 0 {
                    self.foulsLabel.text = String(format: "%g", fouls)
                }
            }
            
            self.earnedFoulsLabel.text = nil
            if let fouls = statistics.opponentFouls as? Float {
                if fouls > 0 {
                    self.earnedFoulsLabel.text = String(format: "%g", fouls)
                }
            }
            
            self.plusMinusLabel.text = nil
            // У тренеров не показываем нули
            if statistics.playerNumber?.intValue != 1000 {
                self.plusMinusLabel.text = "0"
                if let plusMinus = statistics.plusMinus as? Float {
                    self.plusMinusLabel.text = String(format: "%g", plusMinus)
                }
            }
        }
    }
    
    var gameStatistics: GameStatistics! {
        didSet {
            if gameStatistics.player == nil {
                self.teamReboundsHeight.constant = 27
                
                if #available(iOS 8.2, *) {
                    self.playerLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
                    for subview in self.scrollContentView.subviews {
                        if let label = subview as? UILabel {
                            if label != self.onePercentLabel &&
                                label != self.twoPercentLabel &&
                                label != self.threePercentLabel &&
                                label != self.teamReboundsLabel &&
                                label != self.teamReboundsOLabel &&
                                label != self.teamReboundsDLabel {
                                label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
                            }
                        }
                    }
                }
                
                self.totalBackground.isHidden = false
                // Когда рассматривается статистика команды, интересны только
                // проценты бросков. Средние значения обрабатываются
                // аналогично статистике игрока
                self.numberLabel.text = nil
                self.playerLabel.text = self.total
                
                self.twoPercentLabel.text = "0"
                if let goal2 = gameStatistics.goal2?.doubleValue {
                    if let shot2 = gameStatistics.shot2?.doubleValue {
                        if shot2 > 0 {
                            self.twoPercentLabel.text = String(format: "%.1f%%", 100*goal2/shot2)
                        }
                    }
                }
                
                self.threePercentLabel.text = "0"
                if let goal3 = gameStatistics.goal3?.doubleValue {
                    if let shot3 = gameStatistics.shot3?.doubleValue {
                        if shot3 > 0 {
                            self.threePercentLabel.text = String(format: "%.1f%%", 100*goal3/shot3)
                        }
                    }
                }
                
                self.onePercentLabel.text = "0"
                if let goal1 = gameStatistics.goal1?.doubleValue {
                    if let shot1 = gameStatistics.shot1?.doubleValue {
                        if shot1 > 0 {
                            self.onePercentLabel.text = String(format: "%.1f%%", 100*goal1/shot1)
                        }
                    }
                }
                
                self.teamReboundsOLabel.text = nil
                let offs = gameStatistics.teamOffensiveRebounds as? Float ?? 0
                if offs > 0 {
                    self.teamReboundsOLabel.text = String(format: "%g", offs)
                }
                
                self.teamReboundsDLabel.text = nil
                let defs = gameStatistics.teamDefensiveRebounds as? Float ?? 0
                if defs > 0 {
                    self.teamReboundsDLabel.text = String(format: "%g", defs)
                }
                
                self.teamReboundsLabel.text = nil
                if offs + defs > 0 {
                    self.teamReboundsLabel.text = String(format: "%g", offs + defs)
                }
            } else {
                self.teamReboundsHeight.constant = 0
                self.teamReboundsLabel.text = nil
                self.teamReboundsDLabel.text = nil
                self.teamReboundsOLabel.text = nil
                self.onePercentLabel.text = nil
                self.threePercentLabel.text = nil
                self.threePercentLabel.text = nil
                
                self.playerLabel.font = UIFont.systemFont(ofSize: 15)
                for subview in self.scrollContentView.subviews {
                    if let label = subview as? UILabel {
                        label.font = UIFont.systemFont(ofSize: 15)
                    }
                }
                
                self.totalBackground.isHidden = true
                
                if gameStatistics.isStart?.boolValue ?? false {
                    if #available(iOS 8.2, *) {
                        self.playerLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
                    } else {
                        self.playerLabel.font = UIFont.boldSystemFont(ofSize: 15)
                    }
                } else {
                    self.playerLabel.font = UIFont.systemFont(ofSize: 15)
                }
                
                if let playerNumber = gameStatistics.playerNumber {
                    if playerNumber.intValue == 1000 {
                        self.numberLabel.text = NSLocalizedString("Coach acronym", comment: "")
                    } else {
                        self.numberLabel.text = "\(playerNumber)"
                    }
                }
                
                let isLanguageRu = self.language.contains("ru")
                
                self.playerLabel.lineBreakMode = .byClipping
                if var playerName = isLanguageRu ? gameStatistics.player?.lastNameRu : gameStatistics.player?.lastNameEn {
                    if let firstName = isLanguageRu ? gameStatistics.player?.firstNameRu : gameStatistics.player?.firstNameEn {
                        if let firstLetter = firstName[0] {
                            playerName += " \(firstLetter)."
                        }
                    }
                    
                    self.playerLabel.text = "\(playerName)"
                } else {
                    self.playerLabel.text = nil
                }
            }
            
            // Статистика или для команды, или для игрока
            self.timeLabel.text = nil
            if let seconds = gameStatistics.seconds as? Int {
                if seconds > 0 {
                    let mins = seconds/60
                    let secs = seconds%60
                    self.timeLabel.text = String(format: "\(mins):%02zd", secs)
                }
            }
            
            self.pointsLabel.text = nil
            if let pts = gameStatistics.points as? Float {
                if pts > 0 {
                    self.pointsLabel.text = String(format: "%g", pts)
                }
            }
            
            self.twoLabel.text = nil
            if let shot = gameStatistics.shot2 as? Float {
                if shot > 0 {
                    if let goal = gameStatistics.goal2 as? Float  {
                        self.twoLabel.text = String(format: "%g/%g", goal, shot)
                    } else {
                        self.twoLabel.text = String(format: "0/%g", shot)
                    }
                }
            }
            
            self.threeLabel.text = nil
            if let shot = gameStatistics.shot3 as? Float {
                if shot > 0 {
                    if let goal = gameStatistics.goal3 as? Float  {
                        threeLabel.text = String(format: "%g/%g", goal, shot)
                    } else {
                        threeLabel.text = String(format: "0/%g", shot)
                    }
                }
            }
            
            self.oneLabel.text = nil
            if let shot = gameStatistics.shot1 as? Float {
                if shot > 0 {
                    if let goal = gameStatistics.goal1 as? Float {
                        self.oneLabel.text = String(format: "%g/%g", goal, shot)
                    } else {
                        self.oneLabel.text = String(format: "0/%g", shot)
                    }
                }
            }
            
            self.reboundsOLabel.text = nil
            let offs = gameStatistics.offensiveRebounds as? Float ?? 0
            if offs > 0 {
                self.reboundsOLabel.text = String(format: "%g", offs)
            }
            
            self.reboundsDLabel.text = nil
            let defs = gameStatistics.defensiveRebounds as? Float ?? 0
            if defs > 0 {
                self.reboundsDLabel.text = String(format: "%g", defs)
            }
            
            self.reboundsLabel.text = nil
            if offs + defs > 0 {
                self.reboundsLabel.text = String(format: "%g", offs + defs)
            }
            
            self.assistsLabel.text = nil
            if let assists = gameStatistics.assists as? Float {
                if assists > 0 {
                    assistsLabel.text = String(format: "%g", assists)
                }
            }
            
            self.stealsLabel.text = nil
            if let steals = gameStatistics.steals as? Float {
                if steals > 0 {
                    self.stealsLabel.text = String(format: "%g", steals)
                }
            }
            
            self.turnoversLabel.text = nil
            if let turnovers = gameStatistics.turnovers as? Float {
                if turnovers > 0 {
                    self.turnoversLabel.text = String(format: "%g", turnovers)
                }
            }
            
            self.blocksLabel.text = nil
            if let blocks = gameStatistics.blocks as? Float {
                if blocks > 0 {
                    self.blocksLabel.text = String(format: "%g", blocks)
                }
            }
            
            self.foulsLabel.text = nil
            if let fouls = gameStatistics.fouls as? Float {
                if fouls > 0 {
                    self.foulsLabel.text = String(format: "%g", fouls)
                }
            }
            
            self.earnedFoulsLabel.text = nil
            if let fouls = gameStatistics.opponentFouls as? Float {
                if fouls > 0 {
                    self.earnedFoulsLabel.text = String(format: "%g", fouls)
                }
            }
            
            self.plusMinusLabel.text = nil
            // У тренеров не показываем нули
            if gameStatistics.playerNumber?.intValue != 1000 {
                self.plusMinusLabel.text = "0"
                if let plusMinus = gameStatistics.plusMinus as? Float {
                    self.plusMinusLabel.text = String(format: "%g", plusMinus)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.scrollView.scrollsToTop = false
        
        self.numberLabel.highlightedTextColor = UIColor.mlblLightOrangeColor()
        self.playerLabel.highlightedTextColor = UIColor.mlblLightOrangeColor()
        for subview in self.scrollContentView.subviews {
            if let label = subview as? UILabel {
                label.highlightedTextColor = UIColor.mlblLightOrangeColor()
            }
        }
        
        self.teamLabel.text = NSLocalizedString("Team", comment: "")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = self.background.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if (selected) {
            self.background.backgroundColor = color
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = self.background.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        
        if (highlighted) {
            self.background.backgroundColor = color
        }
    }
}

extension StatisticCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize != CGSize.zero {
            self.delegate?.cell(self, didScrollTo: scrollView.contentOffset, tag: self.tag)
        }
    }
}
