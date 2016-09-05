//
//  TeamGameCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 03.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class TeamGameCell: UITableViewCell {

    var language: String!
    var dateFormatter: NSDateFormatter!
    var color: UIColor? {
        didSet {
            self.background.backgroundColor = color
        }
    }
    var teamOfInterest: Team?
    
    var game: Game! {
        didSet {
            if let date = game.date {
                self.dateLabel.text = self.dateFormatter.stringFromDate(date)
            } else {
                self.dateLabel.text = nil
            }
            
            var leftScore: String
            if let scoreA = game.scoreA {
                leftScore = "\(scoreA)"
            } else {
                leftScore = "-"
            }
            
            var rightScore: String
            if let scoreB = game.scoreB {
                rightScore = "\(scoreB)"
            } else {
                rightScore = "-"
            }
            
            let isLanguageRu = self.language.containsString("ru")
            
            if self.teamOfInterest?.shortNameRu == game.shortTeamNameAru {
                self.opponentLabel.text = isLanguageRu ? game.shortTeamNameBru : game.shortTeamNameBen
                self.homeImageView.hidden = false
                
                self.scoreLabel.text = "\(leftScore):\(rightScore)"
            } else {
                self.opponentLabel.text = isLanguageRu ? game.shortTeamNameAru : game.shortTeamNameAen
                self.homeImageView.hidden = true
                
                self.scoreLabel.text = "\(rightScore):\(leftScore)"
            }
        }
    }
    
    var isLast = false
    
    @IBOutlet private var background: UIView!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var homeImageView: UIImageView!
    @IBOutlet private var opponentLabel: UILabel!
    @IBOutlet private var scoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for label in self.background.subviews {
            (label as? UILabel)?.highlightedTextColor = UIColor.mlblLightOrangeColor()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        if self.isLast {
//            let path = UIBezierPath(roundedRect: self.background.bounds,
//                                    byRoundingCorners:[.BottomLeft, .BottomRight],
//                                    cornerRadii:CGSizeMake(5, 5))
//            let maskLayer = CAShapeLayer()
//            maskLayer.path = path.CGPath
//            self.background.layer.mask = maskLayer
//            
//            self.background.layer.shadowRadius = 1
//            self.background.layer.masksToBounds = true
//            self.background.layer.shadowOffset = CGSizeMake(1, 1)
//            self.background.layer.shadowOpacity = 0.5
//            self.background.layer.masksToBounds = false
//            self.background.clipsToBounds = false
//        } else {
//            let path = UIBezierPath()
//            path.moveToPoint(CGPointMake(0, 0))
//            path.addLineToPoint(CGPointMake(self.background.frame.size.width, 0))
//            path.addLineToPoint(CGPointMake(self.background.frame.size.width, self.background.frame.size.height))
//            path.addLineToPoint(CGPointMake(0, self.background.frame.size.height))
//            path.closePath()
//            let maskLayer = CAShapeLayer()
//            maskLayer.path = path.CGPath
//            self.background.layer.mask = maskLayer
//        }
        
        let isLanguageRu = self.language.containsString("ru")
        if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
            if self.teamOfInterest?.shortNameRu == game.shortTeamNameAru {
                self.opponentLabel.text = isLanguageRu ? game.shortTeamNameBru : game.shortTeamNameBen
            } else {
                self.opponentLabel.text = isLanguageRu ? game.shortTeamNameAru : game.shortTeamNameAen
            }
        } else {
            if self.teamOfInterest?.nameRu == game.teamNameAru {
                self.opponentLabel.text = isLanguageRu ? game.teamNameBru : game.teamNameBen
            } else {
                self.opponentLabel.text = isLanguageRu ? game.teamNameAru : game.teamNameAen
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