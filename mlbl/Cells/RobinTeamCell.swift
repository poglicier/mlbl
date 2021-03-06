//
//  RobinTeamCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 23.08.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class RobinTeamCell: UITableViewCell {

    @IBOutlet fileprivate var background: UIView!
    @IBOutlet fileprivate var placeLabel: UILabel!
    @IBOutlet fileprivate var teamNameLabel: UILabel!
    @IBOutlet fileprivate var pointsLabel: UILabel!
    @IBOutlet fileprivate var pointsValueLabel: UILabel!
    @IBOutlet fileprivate var winsLabel: UILabel!
    @IBOutlet fileprivate var winsValueLabel: UILabel!
    @IBOutlet fileprivate var diffLabel: UILabel!
    @IBOutlet fileprivate var diffValueLabel: UILabel!
    @IBOutlet fileprivate var avatarView: UIImageView!
    @IBOutlet fileprivate var separatorLine1: UIView!
    @IBOutlet fileprivate var separatorLine2: UIView!
    
    var language: String!
    
    var rank: TeamRoundRank! {
        didSet {
            self.placeLabel.text = String(format: "%@", rank.place ?? "")
            self.avatarView.image = UIImage(named: "teamStub")
            
            if let team = rank.team {
                
                if let teamId = team.objectId {
                    if let url = URL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamId)") {
                        self.avatarView.setImageWithUrl(url)
                    }
                }
                
                let isLanguageRu = self.language.contains("ru")
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
        self.background.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.background.layer.shadowOpacity = 0.5
        self.background.layer.masksToBounds = false
        self.background.clipsToBounds = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = self.background.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if (selected) {
            self.background.backgroundColor = color
        }
        
        self.separatorLine1.backgroundColor = UIColor.mlblLightOrangeColor()
        self.separatorLine2.backgroundColor = UIColor.mlblLightOrangeColor()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = self.background.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        
        if (highlighted) {
            self.background.backgroundColor = color
        }
        
        self.separatorLine1.backgroundColor = UIColor.mlblLightOrangeColor()
        self.separatorLine2.backgroundColor = UIColor.mlblLightOrangeColor()
    }
}
