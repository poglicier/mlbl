//
//  RobinTeamCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 23.08.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class RobinTeamCell: UITableViewCell {

    @IBOutlet private var background: UIView!
    @IBOutlet private var placeLabel: UILabel!
    @IBOutlet private var teamNameLabel: UILabel!
    @IBOutlet private var pointsLabel: UILabel!
    @IBOutlet private var pointsValueLabel: UILabel!
    @IBOutlet private var winsLabel: UILabel!
    @IBOutlet private var winsValueLabel: UILabel!
    @IBOutlet private var diffLabel: UILabel!
    @IBOutlet private var diffValueLabel: UILabel!
    @IBOutlet private var avatarView: UIImageView!
    @IBOutlet private var separatorLine1: UIView!
    @IBOutlet private var separatorLine2: UIView!
    
    var language: String!
    
    var rank: TeamRoundRank! {
        didSet {
            self.placeLabel.text = String(format: "%@", rank.place ?? "")
            self.avatarView.image = UIImage(named: "teamStub")
            
            if let team = rank.team {
                
                if let teamId = team.objectId {
                    if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamId)") {
                        self.avatarView.setImageWithUrl(url)
                    }
                }
                
                let isLanguageRu = self.language.containsString("ru")
                self.teamNameLabel.text = isLanguageRu ? team.nameRu : team.nameEn

                self.winsValueLabel.text = "\(rank.standingWin ?? 0) - \(rank.standingLose ?? 0)"
                self.diffValueLabel.text = "\(rank.standingsGoalPlus ?? 0) - \(rank.standingsGoalMinus ?? 0)"
                self.pointsValueLabel.text = "\(rank.standingPoints ?? 0)"
            } else {
                self.teamNameLabel.text = nil
                self.winsValueLabel.text = nil
                self.diffValueLabel.text = nil
                self.pointsValueLabel.text = nil
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.pointsLabel.text = NSLocalizedString("Points", comment: "") + ":"
        self.winsLabel.text = NSLocalizedString("Wins", comment: "") + ":"
        self.diffLabel.text = NSLocalizedString("Difference", comment: "") + ":"
        self.teamNameLabel.highlightedTextColor = UIColor.mlblLightOrangeColor()
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
    }

    override func setSelected(selected: Bool, animated: Bool) {
        let color = self.background.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if (selected) {
            self.background.backgroundColor = color
        }
        
        self.separatorLine1.backgroundColor = UIColor.mlblLightOrangeColor()
        self.separatorLine2.backgroundColor = UIColor.mlblLightOrangeColor()
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let color = self.background.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        
        if (highlighted) {
            self.background.backgroundColor = color
        }
        
        self.separatorLine1.backgroundColor = UIColor.mlblLightOrangeColor()
        self.separatorLine2.backgroundColor = UIColor.mlblLightOrangeColor()
    }
}