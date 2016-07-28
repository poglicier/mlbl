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
    @IBOutlet private var teamAvatar: UIImageView!
    @IBOutlet private var teamNameLabel: UILabel!
    @IBOutlet private var numberLabel: UILabel!
    @IBOutlet private var playerLabel: UILabel!
    
    var language: String!
    
    var statistics: GameStatistics? {
        didSet {
            let isLanguageRu = self.language.containsString("ru")
            
            if let team = statistics?.team {
                if let teamAId = team.objectId {
                    if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamAId)") {
                        self.teamAvatar.setImageWithUrl(url)
                    }
                }
                self.teamNameLabel.text = isLanguageRu ? team.nameRu : team.nameEn
            } else {
                self.teamNameLabel.text = nil
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
//        let path = UIBezierPath(roundedRect:self.bottomGrayView.bounds, byRoundingCorners:[.BottomRight, .BottomLeft], cornerRadii: CGSizeMake(5, 5))
//        let maskLayer = CAShapeLayer()
//        maskLayer.path = path.CGPath
//        self.bottomGrayView.layer.mask = maskLayer
        
        self.background.layer.cornerRadius = 5
        self.background.layer.shadowRadius = 1
        self.background.layer.masksToBounds = true
        self.background.layer.shadowOffset = CGSizeMake(1, 1)
        self.background.layer.shadowOpacity = 0.5
        self.background.layer.masksToBounds = false
        self.background.clipsToBounds = false
        
        if let team = self.statistics?.team {
            let isLanguageRu = self.language.containsString("ru")

            if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
                self.teamNameLabel.text = isLanguageRu ? team.shortNameRu : team.shortNameEn
            } else {
                self.teamNameLabel.text = isLanguageRu ? team.nameRu : team.nameEn
            }
        }
    }
}