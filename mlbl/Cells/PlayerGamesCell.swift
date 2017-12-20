//
//  PlayerGamesCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 05.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

protocol PlayerGamesCellDelegate {
    func cell(_ cell: PlayerGamesCell, didScrollTo contentOffset: CGPoint, tag: Int)
}

class PlayerGamesCell: UITableViewCell {
    
    // MARK: - Private
    
    @IBOutlet fileprivate var background: UIView!
    @IBOutlet fileprivate var totalBackground: UIView!
    @IBOutlet fileprivate var percentBackground: UIView!
    @IBOutlet fileprivate var guestLabel: UILabel!
    @IBOutlet fileprivate var hostLabel: UILabel!
    @IBOutlet fileprivate var totalLabel: UILabel!
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
    @IBOutlet fileprivate var scoreLabel: UILabel!
    @IBOutlet fileprivate var dateLabel: UILabel!
    @IBOutlet fileprivate var scrollContentView: UIView!
    @IBOutlet fileprivate var scrollView: TappableScrollView!
    @IBOutlet fileprivate var twoPercentLabel: UILabel!
    @IBOutlet fileprivate var threePercentLabel: UILabel!
    @IBOutlet fileprivate var onePercentLabel: UILabel!
    
    fileprivate let fontSize: CGFloat = 15
    fileprivate var addedSubviews = [UIView]()
    
    static fileprivate var dateFormatter: DateFormatter = {
        let res = DateFormatter()
        res.dateFormat = "dd-MM-yyyy"
        return res
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.scrollView.delegate = self
        self.scrollView.scrollsToTop = false
        let tapGestures = self.scrollView.gestureRecognizers?.filter {$0 is UITapGestureRecognizer}
        tapGestures?.forEach {self.scrollView.removeGestureRecognizer($0)}
        
        for subview in self.scrollContentView.subviews {
            if let label = subview as? UILabel {
                label.highlightedTextColor = UIColor.mlblLightOrangeColor()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.addedSubviews.forEach { $0.removeFromSuperview() }
        self.addedSubviews = [UIView]()
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
    
    // MARK: - Public
    
    var language: String!
    var delegate: PlayerGamesCellDelegate?
    var contentOffset: CGPoint! {
        didSet {
            self.scrollView.contentOffset = contentOffset
        }
    }
    
    var color: UIColor? {
        didSet {
            self.background.backgroundColor = color
        }
    }
    var total = ""
    
    var statistics: PlayerStatistics! {
        didSet {
            if statistics.game == nil {
                if #available(iOS 8.2, *) {
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
                
                self.selectionStyle = .none
                self.totalBackground.isHidden = false
                self.totalLabel.text = self.total
                self.hostLabel.text = nil
                self.guestLabel.text = nil
                
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
                
                self.scoreLabel.text = nil
                self.dateLabel.text = nil
            } else {
                self.selectionStyle = .default
                self.totalBackground.isHidden = true
                self.totalLabel.text = nil
            
                let isLanguageRu = self.language.contains("ru")
                
                self.hostLabel.text = isLanguageRu ? statistics.teamA?.shortNameRu : statistics.teamA?.shortNameEn
                self.guestLabel.text = isLanguageRu ? statistics.teamB?.shortNameRu : statistics.teamB?.shortNameEn
                
                self.scoreLabel.text = (statistics.game?.scoreA?.stringValue ?? "-") + ":" + (statistics.game?.scoreB?.stringValue ?? "-")
                
                if let date = statistics.game?.date {
                    self.dateLabel.text = PlayerGamesCell.dateFormatter.string(from: date as Date)
                } else {
                    self.dateLabel.text = nil
                }
            }
            
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
            
            if let plusMinus = statistics.plusMinus as? Float {
                self.plusMinusLabel.text = String(format: "%g", plusMinus)
            } else {
                self.plusMinusLabel.text = "0"
            }
        }
    }
}

extension PlayerGamesCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.cell(self, didScrollTo: scrollView.contentOffset, tag: self.tag)
    }
}
