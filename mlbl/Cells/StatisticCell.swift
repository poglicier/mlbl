//
//  StatisticCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 09.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

protocol StatisticCellDelegate {
    func cell(cell: StatisticCell, didScrollTo contentOffset: CGPoint, tag: Int)
}

class StatisticCell: UITableViewCell {
    
    @IBOutlet private var numberLabel: UILabel!
    @IBOutlet private var playerLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var pointsLabel: UILabel!
    @IBOutlet private var twoLabel: UILabel!
    @IBOutlet private var threeLabel: UILabel!
    @IBOutlet private var oneLabel: UILabel!
    @IBOutlet private var reboundsOLabel: UILabel!
    @IBOutlet private var reboundsDLabel: UILabel!
    @IBOutlet private var reboundsLabel: UILabel!
    @IBOutlet private var assistsLabel: UILabel!
    @IBOutlet private var stealsLabel: UILabel!
    @IBOutlet private var turnoversLabel: UILabel!
    @IBOutlet private var blocksLabel: UILabel!
    @IBOutlet private var foulsLabel: UILabel!
    @IBOutlet private var earnedFoulsLabel: UILabel!
    @IBOutlet private var plusMinusLabel: UILabel!
    @IBOutlet private var scrollContentView: UIView!
    @IBOutlet private var background: UIView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var twoPercentLabel: UILabel!
    @IBOutlet private var threePercentLabel: UILabel!
    @IBOutlet private var onePercentLabel: UILabel!

    var delegate: StatisticCellDelegate?
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
            if statistics.player == nil {
                if #available(iOS 8.2, *) {
                    self.playerLabel.font = UIFont.systemFontOfSize(15, weight: UIFontWeightSemibold)
                    for subview in self.scrollContentView.subviews {
                        if let label = subview as? UILabel {
                            if label != self.onePercentLabel &&
                                label != self.twoPercentLabel &&
                                label != self.threePercentLabel {
                                label.font = UIFont.systemFontOfSize(15, weight: UIFontWeightSemibold)
                            }
                        }
                    }
                }
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
                self.playerLabel.font = UIFont.systemFontOfSize(15)
                for subview in self.scrollContentView.subviews {
                    if let label = subview as? UILabel {
                        label.font = UIFont.systemFontOfSize(15)
                    }
                }
                
                if let playerNumber = statistics.playerNumber {
                    if playerNumber.integerValue == 1000 {
                        self.numberLabel.text = NSLocalizedString("Coach acronym", comment: "")
                    } else {
                        self.numberLabel.text = "\(playerNumber)"
                    }
                }
                
                let isLanguageRu = self.language.containsString("ru")
                
                self.playerLabel.lineBreakMode = .ByClipping
                if var playerName = isLanguageRu ? statistics.player?.lastNameRu : statistics.player?.lastNameEn {
                    if let firstName = isLanguageRu ? statistics.player?.firstNameRu : statistics.player?.firstNameEn {
                        if let firstLetter = firstName.characters.first {
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
            if statistics.playerNumber?.integerValue != 1000 {
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
                if #available(iOS 8.2, *) {
                    self.playerLabel.font = UIFont.systemFontOfSize(15, weight: UIFontWeightSemibold)
                    for subview in self.scrollContentView.subviews {
                        if let label = subview as? UILabel {
                            if label != self.onePercentLabel &&
                                label != self.twoPercentLabel &&
                                label != self.threePercentLabel {
                                label.font = UIFont.systemFontOfSize(15, weight: UIFontWeightSemibold)
                            }
                        }
                    }
                }
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
            } else {
                self.playerLabel.font = UIFont.systemFontOfSize(15)
                for subview in self.scrollContentView.subviews {
                    if let label = subview as? UILabel {
                        label.font = UIFont.systemFontOfSize(15)
                    }
                }
                
                if gameStatistics.isStart?.boolValue ?? false {
                    if #available(iOS 8.2, *) {
                        self.playerLabel.font = UIFont.systemFontOfSize(15, weight: UIFontWeightSemibold)
                    } else {
                        self.playerLabel.font = UIFont.boldSystemFontOfSize(15)
                    }
                } else {
                    self.playerLabel.font = UIFont.systemFontOfSize(15)
                }
                
                if let playerNumber = gameStatistics.playerNumber {
                    if playerNumber.integerValue == 1000 {
                        self.numberLabel.text = NSLocalizedString("Coach acronym", comment: "")
                    } else {
                        self.numberLabel.text = "\(playerNumber)"
                    }
                }
                
                let isLanguageRu = self.language.containsString("ru")
                
                self.playerLabel.lineBreakMode = .ByClipping
                if var playerName = isLanguageRu ? gameStatistics.player?.lastNameRu : gameStatistics.player?.lastNameEn {
                    if let firstName = isLanguageRu ? gameStatistics.player?.firstNameRu : gameStatistics.player?.firstNameEn {
                        if let firstLetter = firstName.characters.first {
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
            if gameStatistics.playerNumber?.integerValue != 1000 {
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
    }

    override func setSelected(selected: Bool, animated: Bool) {
        let color = self.background.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if (selected) {
            self.background.backgroundColor = color
        }
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let color = self.background.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        
        if (highlighted) {
            self.background.backgroundColor = color
        }
    }
}

extension StatisticCell: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.delegate?.cell(self, didScrollTo: scrollView.contentOffset, tag: self.tag)
    }
}