//
//  GameStatsCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 12.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class GameStatsCell: UITableViewCell {
    
    @IBOutlet private var background: UIView!
    @IBOutlet private var hatBackground: UIView!
    @IBOutlet private var totalBackground: UIView!
    @IBOutlet private var percentBackground: UIView!
    @IBOutlet private var teamAvatar: UIImageView!
    @IBOutlet private var teamNameLabel: UILabel!
    @IBOutlet private var numberLabel: UILabel!
    @IBOutlet private var playerLabel: UILabel!
    @IBOutlet private var totalLabel: UILabel!
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
    @IBOutlet private var scrollView: UIScrollView!
    
    private let fontSize: CGFloat = 15
    
    var language: String!
    var teamNumber: Int!
    var game: Game? {
        didSet {
            let isLanguageRu = self.language.containsString("ru")
            
            self.teamNameLabel.text = nil
            if var statistics = ((self.game?.statistics as? Set<GameStatistics>)?.filter {$0.teamNumber?.integerValue == self.teamNumber}) {
                // Сортируем статистику: сначала игроки по номерам, затем команда
                statistics = statistics.sort({ (first, second) -> Bool in
                    if first.player == nil {
                        return false
                    } else if second.player == nil {
                        return true
                    } else {
                        return (first.playerNumber?.integerValue ?? 0) < (second.playerNumber?.integerValue ?? 0)
                    }
                })
                
                var predLine: UIView?
                var predMinsLabel: UILabel?
                
                for (idx, stat) in statistics.enumerate() {
                    if let team = stat.team {
                        // Заполняем шапку с названием команды и аватаркой
                        if let teamAId = team.objectId {
                            if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamAId)") {
                                self.teamAvatar.setImageWithUrl(url)
                            }
                        }
                        self.teamNameLabel.text = isLanguageRu ? team.nameRu : team.nameEn
                        
                        let backgroundLine = UIView()
                        backgroundLine.backgroundColor = (idx % 2 == 0) ? UIColor(red: 254/255.0, green: 254/255.0, blue: 254/255.0, alpha: 1) : UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
                        self.background.insertSubview(backgroundLine, atIndex: 0)
                        backgroundLine.snp_makeConstraints(closure: { (make) in
                            make.left.right.equalTo(0)
                            make.height.equalTo(27)
                            if let _ = predLine {
                                make.top.equalTo(predLine!.snp_bottom)
                            } else {
                                make.top.equalTo(self.hatBackground.snp_bottom)
                            }
                        })
                        
                        // Статистика Команды
                        let numberLabel = UILabel()
                        numberLabel.font = UIFont.systemFontOfSize(self.fontSize)
                        numberLabel.text = NSLocalizedString("Team", comment: "")
                        backgroundLine.addSubview(numberLabel)
                        numberLabel.snp_makeConstraints(closure: { (make) in
                            make.left.equalTo(12)
                            make.top.bottom.equalTo(0)
                        })
                        
                        let minutesLabel = UILabel()
                        self.scrollContentView.addSubview(minutesLabel)
                        minutesLabel.snp_makeConstraints(closure: { (make) in
                            make.left.equalTo(0)
                            make.width.equalTo(self.timeLabel.snp_width)
                            make.height.equalTo(self.timeLabel.snp_height)
                            
                            if let _ = predMinsLabel {
                                make.top.equalTo(predMinsLabel!.snp_bottom)
                            } else {
                                make.top.equalTo(self.timeLabel.snp_bottom)
                            }
                        })
                        predMinsLabel = minutesLabel
                        
                        let offLabel = UILabel()
                        offLabel.font = UIFont.systemFontOfSize(self.fontSize)
                        offLabel.textAlignment = .Center
                        offLabel.text = nil
                        let offs = stat.teamOffensiveRebounds as? Int ?? 0
                        if offs > 0 {
                            offLabel.text = "\(offs)"
                        }
                        self.scrollContentView.addSubview(offLabel)
                        offLabel.snp_makeConstraints(closure: { (make) in
                            make.left.equalTo(oneLabel.snp_right)
                            make.width.equalTo(oneLabel.snp_width)
                            make.height.equalTo(oneLabel.snp_height)
                            make.top.equalTo(oneLabel.snp_top)
                        })
                        
                        let defLabel = UILabel()
                        defLabel.font = UIFont.systemFontOfSize(self.fontSize)
                        defLabel.textAlignment = .Center
                        defLabel.text = nil
                        let defs = stat.teamDefensiveRebounds as? Int ?? 0
                        if defs > 0 {
                            defLabel.text = "\(defs)"
                        }
                        self.scrollContentView.addSubview(defLabel)
                        defLabel.snp_makeConstraints(closure: { (make) in
                            make.left.equalTo(offLabel.snp_right)
                            make.width.equalTo(offLabel.snp_width)
                            make.height.equalTo(offLabel.snp_height)
                            make.top.equalTo(predLine!.snp_bottom)
                        })
                        
                        let rebLabel = UILabel()
                        rebLabel.font = UIFont.systemFontOfSize(self.fontSize)
                        rebLabel.textAlignment = .Center
                        rebLabel.text = nil
                        if offs + defs > 0 {
                            rebLabel.text = "\(offs + defs)"
                        }
                        self.scrollContentView.addSubview(rebLabel)
                        rebLabel.snp_makeConstraints(closure: { (make) in
                            make.left.equalTo(defLabel.snp_right)
                            make.width.equalTo(defLabel.snp_width)
                            make.height.equalTo(defLabel.snp_height)
                            make.top.equalTo(defLabel.snp_top)
                        })
                        
                        // Статистика Проценты бросков
                        let twoPercentLabel = UILabel()
                        twoPercentLabel.font = UIFont.systemFontOfSize(self.fontSize)
                        twoPercentLabel.textAlignment = .Center
                        twoPercentLabel.text = "0"
                        if let goal2 = stat.goal2?.doubleValue {
                            if let shot2 = stat.shot2?.doubleValue {
                                if shot2 > 0 {
                                    twoPercentLabel.text = String(format: "%.1f%%", 100*goal2/shot2)
                                }
                            }
                        }
                        self.scrollContentView.addSubview(twoPercentLabel)
                        twoPercentLabel.snp_makeConstraints(closure: { (make) in
                            make.left.equalTo(self.twoLabel.snp_left)
                            make.width.equalTo(self.twoLabel.snp_width)
                            make.height.equalTo(self.twoLabel.snp_height)
                            make.top.equalTo(self.percentBackground!.snp_top)
                        })
                        
                        let threePercentLabel = UILabel()
                        threePercentLabel.font = UIFont.systemFontOfSize(self.fontSize)
                        threePercentLabel.textAlignment = .Center
                        threePercentLabel.text = "0"
                        if let goal3 = stat.goal3?.doubleValue {
                            if let shot3 = stat.shot3?.doubleValue {
                                if shot3 > 0 {
                                    threePercentLabel.text = String(format: "%.1f%%", 100*goal3/shot3)
                                }
                            }
                        }
                        self.scrollContentView.addSubview(threePercentLabel)
                        threePercentLabel.snp_makeConstraints(closure: { (make) in
                            make.left.equalTo(self.threeLabel.snp_left)
                            make.width.equalTo(self.threeLabel.snp_width)
                            make.height.equalTo(self.threeLabel.snp_height)
                            make.top.equalTo(self.percentBackground!.snp_top)
                        })
                        
                        let onePercentLabel = UILabel()
                        onePercentLabel.font = UIFont.systemFontOfSize(self.fontSize)
                        onePercentLabel.textAlignment = .Center
                        onePercentLabel.text = "0"
                        if let goal1 = stat.goal1?.doubleValue {
                            if let shot1 = stat.shot1?.doubleValue {
                                if shot1 > 0 {
                                    onePercentLabel.text = String(format: "%.1f%%", 100*goal1/shot1)
                                }
                            }
                        }
                        self.scrollContentView.addSubview(onePercentLabel)
                        onePercentLabel.snp_makeConstraints(closure: { (make) in
                            make.left.equalTo(self.oneLabel.snp_left)
                            make.width.equalTo(self.oneLabel.snp_width)
                            make.height.equalTo(self.oneLabel.snp_height)
                            make.top.equalTo(self.percentBackground!.snp_top)
                        })
                    }
                        
                    var backgroundLine: UIView
                    if let _ = stat.team {
                        backgroundLine = self.totalBackground
                    } else {
                        backgroundLine = UIView()
                        backgroundLine.backgroundColor = (idx % 2 == 0) ? UIColor(red: 254/255.0, green: 254/255.0, blue: 254/255.0, alpha: 1) : UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
                        self.background.insertSubview(backgroundLine, atIndex: 0)
                        backgroundLine.snp_makeConstraints(closure: { (make) in
                            make.left.right.equalTo(0)
                            make.height.equalTo(27)
                            if let _ = predLine {
                                make.top.equalTo(predLine!.snp_bottom)
                            } else {
                                make.top.equalTo(self.hatBackground.snp_bottom)
                            }
                        })
                        
                        predLine = backgroundLine
                    
                        let numberLabel = UILabel()
                        numberLabel.textAlignment = .Center
                        numberLabel.font = UIFont.systemFontOfSize(self.fontSize)
                        if let playerNumber = stat.playerNumber {
                            if playerNumber.integerValue == 1000 {
                                numberLabel.text = NSLocalizedString("Coach acronym", comment: "")
                            } else {
                                numberLabel.text = "\(playerNumber)"
                            }
                        }
                        backgroundLine.addSubview(numberLabel)
                        numberLabel.snp_makeConstraints(closure: { (make) in
                            make.left.top.bottom.equalTo(0)
                            make.width.equalTo(44)
                        })
                        
                        let nameLabel = UILabel()
                        nameLabel.lineBreakMode = .ByClipping
                        if stat.isStart?.boolValue ?? false {
                            if #available(iOS 8.2, *) {
                                nameLabel.font = UIFont.systemFontOfSize(self.fontSize, weight: UIFontWeightSemibold)
                            } else {
                                nameLabel.font = UIFont.boldSystemFontOfSize(self.fontSize)
                            }
                        } else {
                            nameLabel.font = UIFont.systemFontOfSize(self.fontSize)
                        }
                        if var playerName = isLanguageRu ? stat.player?.lastNameRu : stat.player?.lastNameEn {
                            if let firstName = isLanguageRu ? stat.player?.firstNameRu : stat.player?.firstNameEn {
                                if let firstLetter = firstName.characters.first {
                                    playerName += " \(firstLetter)."
                                }
                            }
                            
                            nameLabel.text = "\(playerName)"
                        } else {
                            nameLabel.text = nil
                        }
                        
                        backgroundLine.addSubview(nameLabel)
                        nameLabel.snp_makeConstraints(closure: { (make) in
                            make.top.bottom.equalTo(0)
                            make.right.equalTo(self.playerLabel.snp_right)
                            make.left.equalTo(numberLabel.snp_right)
                        })
                    }
                    
                    let minutesLabel = UILabel()
                    minutesLabel.font = UIFont.systemFontOfSize(self.fontSize)
                    minutesLabel.textAlignment = .Center
                    minutesLabel.text = nil
                    if let seconds = stat.seconds as? Int {
                        if seconds > 0 {
                            let mins = seconds/60
                            let secs = seconds%60
                            minutesLabel.text = String(format: "\(mins):%02zd", secs)
                        }
                    }
                    self.scrollContentView.addSubview(minutesLabel)
                    minutesLabel.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(0)
                        make.width.equalTo(self.timeLabel.snp_width)
                        make.height.equalTo(self.timeLabel.snp_height)
                        
                        if let _ = predMinsLabel {
                            make.top.equalTo(predMinsLabel!.snp_bottom)
                        } else {
                            make.top.equalTo(self.timeLabel.snp_bottom)
                        }
                    })
                    predMinsLabel = minutesLabel
                    
                    let ptsLabel = UILabel()
                    ptsLabel.font = UIFont.systemFontOfSize(self.fontSize)
                    ptsLabel.textAlignment = .Center
                    ptsLabel.text = nil
                    if let pts = stat.points as? Int {
                        if pts > 0 {
                            ptsLabel.text = "\(pts)"
                        }
                    }
                    self.scrollContentView.addSubview(ptsLabel)
                    ptsLabel.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(minutesLabel.snp_right)
                        make.width.equalTo(minutesLabel.snp_width)
                        make.height.equalTo(minutesLabel.snp_height)
                        make.top.equalTo(minutesLabel.snp_top)
                    })
                    
                    let twoPtsLabel = UILabel()
                    twoPtsLabel.font = UIFont.systemFontOfSize(self.fontSize)
                    twoPtsLabel.textAlignment = .Center
                    twoPtsLabel.text = nil
                    if let shot = stat.shot2 as? Int {
                        if shot > 0 {
                            if let goal = stat.goal2 {
                                twoPtsLabel.text = "\(goal)/\(shot)"
                            } else {
                                twoPtsLabel.text = "0/\(shot)"
                            }
                        }
                    }
                    self.scrollContentView.addSubview(twoPtsLabel)
                    twoPtsLabel.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(ptsLabel.snp_right)
                        make.width.equalTo(ptsLabel.snp_width)
                        make.height.equalTo(ptsLabel.snp_height)
                        make.top.equalTo(ptsLabel.snp_top)
                    })
                    
                    let threePtsLabel = UILabel()
                    threePtsLabel.font = UIFont.systemFontOfSize(self.fontSize)
                    threePtsLabel.textAlignment = .Center
                    threePtsLabel.text = nil
                    if let shot = stat.shot3 as? Int {
                        if shot > 0 {
                            if let goal = stat.goal3 {
                                threePtsLabel.text = "\(goal)/\(shot)"
                            } else {
                                threePtsLabel.text = "0/\(shot)"
                            }
                        }
                    }
                    self.scrollContentView.addSubview(threePtsLabel)
                    threePtsLabel.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(twoPtsLabel.snp_right)
                        make.width.equalTo(twoPtsLabel.snp_width)
                        make.height.equalTo(twoPtsLabel.snp_height)
                        make.top.equalTo(twoPtsLabel.snp_top)
                    })
                    
                    let onePtsLabel = UILabel()
                    onePtsLabel.font = UIFont.systemFontOfSize(self.fontSize)
                    onePtsLabel.textAlignment = .Center
                    onePtsLabel.text = nil
                    if let shot = stat.shot1 as? Int {
                        if shot > 0 {
                            if let goal = stat.goal1 {
                                onePtsLabel.text = "\(goal)/\(shot)"
                            } else {
                                onePtsLabel.text = "0/\(shot)"
                            }
                        }
                    }
                    self.scrollContentView.addSubview(onePtsLabel)
                    onePtsLabel.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(threePtsLabel.snp_right)
                        make.width.equalTo(threePtsLabel.snp_width)
                        make.height.equalTo(threePtsLabel.snp_height)
                        make.top.equalTo(threePtsLabel.snp_top)
                    })
                    
                    let offLabel = UILabel()
                    offLabel.font = UIFont.systemFontOfSize(self.fontSize)
                    offLabel.textAlignment = .Center
                    offLabel.text = nil
                    let offs = stat.offensiveRebounds as? Int ?? 0
                    if offs > 0 {
                        offLabel.text = "\(offs)"
                    }
                    self.scrollContentView.addSubview(offLabel)
                    offLabel.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(onePtsLabel.snp_right)
                        make.width.equalTo(onePtsLabel.snp_width)
                        make.height.equalTo(onePtsLabel.snp_height)
                        make.top.equalTo(onePtsLabel.snp_top)
                    })
                    
                    let defLabel = UILabel()
                    defLabel.font = UIFont.systemFontOfSize(self.fontSize)
                    defLabel.textAlignment = .Center
                    defLabel.text = nil
                    let defs = stat.defensiveRebounds as? Int ?? 0
                    if defs > 0 {
                        defLabel.text = "\(defs)"
                    }
                    self.scrollContentView.addSubview(defLabel)
                    defLabel.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(offLabel.snp_right)
                        make.width.equalTo(offLabel.snp_width)
                        make.height.equalTo(offLabel.snp_height)
                        make.top.equalTo(offLabel.snp_top)
                    })
                    
                    let rebLabel = UILabel()
                    rebLabel.font = UIFont.systemFontOfSize(self.fontSize)
                    rebLabel.textAlignment = .Center
                    rebLabel.text = nil
                    if offs + defs > 0 {
                        rebLabel.text = "\(offs + defs)"
                    }
                    self.scrollContentView.addSubview(rebLabel)
                    rebLabel.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(defLabel.snp_right)
                        make.width.equalTo(defLabel.snp_width)
                        make.height.equalTo(defLabel.snp_height)
                        make.top.equalTo(defLabel.snp_top)
                    })
                    
                    let asLabel = UILabel()
                    asLabel.font = UIFont.systemFontOfSize(self.fontSize)
                    asLabel.textAlignment = .Center
                    asLabel.text = nil
                    if let assists = stat.assists as? Int {
                        if assists > 0 {
                            asLabel.text = "\(assists)"
                        }
                    }
                    self.scrollContentView.addSubview(asLabel)
                    asLabel.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(rebLabel.snp_right)
                        make.width.equalTo(rebLabel.snp_width)
                        make.height.equalTo(rebLabel.snp_height)
                        make.top.equalTo(rebLabel.snp_top)
                    })
                    
                    let stealsLabel = UILabel()
                    stealsLabel.font = UIFont.systemFontOfSize(self.fontSize)
                    stealsLabel.textAlignment = .Center
                    stealsLabel.text = nil
                    if let steals = stat.steals as? Int {
                        if steals > 0 {
                            stealsLabel.text = "\(steals)"
                        }
                    }
                    self.scrollContentView.addSubview(stealsLabel)
                    stealsLabel.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(asLabel.snp_right)
                        make.width.equalTo(asLabel.snp_width)
                        make.height.equalTo(asLabel.snp_height)
                        make.top.equalTo(asLabel.snp_top)
                    })
                    
                    let tLabel = UILabel()
                    tLabel.font = UIFont.systemFontOfSize(self.fontSize)
                    tLabel.textAlignment = .Center
                    tLabel.text = nil
                    if let turnovers = stat.turnovers as? Int {
                        if turnovers > 0 {
                            tLabel.text = "\(turnovers)"
                        }
                    }
                    self.scrollContentView.addSubview(tLabel)
                    tLabel.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(stealsLabel.snp_right)
                        make.width.equalTo(stealsLabel.snp_width)
                        make.height.equalTo(stealsLabel.snp_height)
                        make.top.equalTo(stealsLabel.snp_top)
                    })
                    
                    let blocksLabel = UILabel()
                    blocksLabel.font = UIFont.systemFontOfSize(self.fontSize)
                    blocksLabel.textAlignment = .Center
                    blocksLabel.text = nil
                    if let blocks = stat.blocks as? Int {
                        if blocks > 0 {
                            blocksLabel.text = "\(blocks)"
                        }
                    }
                    self.scrollContentView.addSubview(blocksLabel)
                    blocksLabel.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(tLabel.snp_right)
                        make.width.equalTo(tLabel.snp_width)
                        make.height.equalTo(tLabel.snp_height)
                        make.top.equalTo(tLabel.snp_top)
                    })
                    
                    let foulsLabel = UILabel()
                    foulsLabel.font = UIFont.systemFontOfSize(self.fontSize)
                    foulsLabel.textAlignment = .Center
                    foulsLabel.text = nil
                    if let fouls = stat.fouls as? Int {
                        if fouls > 0 {
                            foulsLabel.text = "\(fouls)"
                        }
                    }
                    self.scrollContentView.addSubview(foulsLabel)
                    foulsLabel.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(blocksLabel.snp_right)
                        make.width.equalTo(blocksLabel.snp_width)
                        make.height.equalTo(blocksLabel.snp_height)
                        make.top.equalTo(blocksLabel.snp_top)
                    })
                    
                    let opponentFoulsLabel = UILabel()
                    opponentFoulsLabel.font = UIFont.systemFontOfSize(self.fontSize)
                    opponentFoulsLabel.textAlignment = .Center
                    opponentFoulsLabel.text = nil
                    if let fouls = stat.opponentFouls as? Int {
                        if fouls > 0 {
                            opponentFoulsLabel.text = "\(fouls)"
                        }
                    }
                    self.scrollContentView.addSubview(opponentFoulsLabel)
                    opponentFoulsLabel.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(foulsLabel.snp_right)
                        make.width.equalTo(foulsLabel.snp_width)
                        make.height.equalTo(foulsLabel.snp_height)
                        make.top.equalTo(foulsLabel.snp_top)
                    })
                    
                    let diffLabel = UILabel()
                    // У тренеров не показываем нули
                    if stat.playerNumber?.integerValue != 1000 {
                        diffLabel.font = UIFont.systemFontOfSize(self.fontSize)
                        diffLabel.textAlignment = .Center
                        diffLabel.text = "0"
                        if let plusMinus = stat.plusMinus as? Int {
                            diffLabel.text = "\(plusMinus)"
                        }
                    }
                    self.scrollContentView.addSubview(diffLabel)
                    diffLabel.snp_makeConstraints(closure: { (make) in
                        make.left.equalTo(opponentFoulsLabel.snp_right)
                        make.width.equalTo(opponentFoulsLabel.snp_width)
                        make.height.equalTo(opponentFoulsLabel.snp_height)
                        make.top.equalTo(opponentFoulsLabel.snp_top)
                    })
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.scrollView.scrollsToTop = false
        self.numberLabel.text = NSLocalizedString("Number", comment: "")
        self.playerLabel.text = NSLocalizedString("Player", comment: "")
        self.totalLabel.text = NSLocalizedString("Total", comment: "").uppercaseString
        self.timeLabel.text = NSLocalizedString("Time", comment: "")
        self.pointsLabel.text = NSLocalizedString("Points", comment: "")
        self.twoLabel.text = NSLocalizedString("Two pts", comment: "")
        self.threeLabel.text = NSLocalizedString("Three pts", comment: "")
        self.oneLabel.text = NSLocalizedString("One pts", comment: "")
        self.reboundsOLabel.text = NSLocalizedString("Rebounds offensive", comment: "")
        self.reboundsDLabel.text = NSLocalizedString("Rebounds defensive", comment: "")
        self.reboundsLabel.text = NSLocalizedString("Rebounds", comment: "")
        self.assistsLabel.text = NSLocalizedString("Assists", comment: "")
        self.stealsLabel.text = NSLocalizedString("Steals", comment: "")
        self.turnoversLabel.text = NSLocalizedString("Turnovers", comment: "")
        self.blocksLabel.text = NSLocalizedString("Blockshots", comment: "")
        self.foulsLabel.text = NSLocalizedString("Fouls", comment: "")
        self.earnedFoulsLabel.text = NSLocalizedString("Earned fouls", comment: "")
        self.plusMinusLabel.text = "+/-"
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.background.layer.cornerRadius = 5
        self.background.layer.shadowRadius = 1
        self.background.layer.masksToBounds = true
        self.background.layer.shadowOffset = CGSizeMake(1, 1)
        self.background.layer.shadowOpacity = 0.5
        self.background.layer.masksToBounds = false
        self.background.clipsToBounds = false
        
        self.teamNameLabel.text = nil
        if let statistics = ((self.game?.statistics as? Set<GameStatistics>)?.filter {$0.teamNumber?.integerValue == self.teamNumber && $0.player == nil })?.first {
            if let team = statistics.team {
                let isLanguageRu = self.language.containsString("ru")

                if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
                    self.teamNameLabel.text = isLanguageRu ? team.shortNameRu : team.shortNameEn
                } else {
                    self.teamNameLabel.text = isLanguageRu ? team.nameRu : team.nameEn
                }
            }
        }
    }
}