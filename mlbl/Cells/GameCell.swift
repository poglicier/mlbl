//
//  GameCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 05.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import Alamofire

class GameCell: UITableViewCell {

    @IBOutlet private var background: UIView!
    @IBOutlet private var avatarA: UIImageView!
    @IBOutlet private var avatarB: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var statusLabel: UILabel!
    @IBOutlet private var teamAScoreLabel: UILabel!
    @IBOutlet private var teamBScoreLabel: UILabel!
    @IBOutlet private var teamANameLabel: UILabel!
    @IBOutlet private var teamBNameLabel: UILabel!
    
    var language: String!
    
    var game: Game! {
        didSet {
            if let teamA = game.teamA {
                if let teamAId = game.teamA?.objectId {
                    if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamAId)") {
                        self.avatarA.setImageWithUrl(url)
                    }
                }
                self.teamANameLabel.text = self.language.containsString("ru") ? teamA.nameRu : teamA.nameEn
            }
            self.teamAScoreLabel.text = game.scoreA?.stringValue ?? "-"
            
            if let teamB = game.teamB {
                if let teamBId = game.teamB?.objectId {
                    if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamBId)") {
                        self.avatarB.setImageWithUrl(url)
                    }
                }
                self.teamBNameLabel.text = self.language.containsString("ru") ? teamB.nameRu : teamB.nameEn
            }
            self.teamBScoreLabel.text = game.scoreB?.stringValue ?? "-"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
