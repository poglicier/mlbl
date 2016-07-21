//
//  GameCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 05.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

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
    
    static private var dateFormatter: NSDateFormatter = {
        let res = NSDateFormatter()
        res.dateFormat = "dd MMMM yyyy, hh:mm"
        return res
    }()
    
    var language: String!
    
    var game: Game! {
        didSet {
            let isLanguageRu = self.language.containsString("ru")
            
            self.avatarA.image = UIImage(named: "teamStub")
            if let teamA = game.teamA {
                if let teamAId = game.teamA?.objectId {
                    if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamAId)") {
                        self.avatarA.setImageWithUrl(url)
                    }
                }
                self.teamANameLabel.text = isLanguageRu ? teamA.nameRu : teamA.nameEn
            }
            self.teamAScoreLabel.text = game.scoreA?.stringValue ?? "-"
            
            self.avatarB.image = UIImage(named: "teamStub")
            if let teamB = game.teamB {
                if let teamBId = game.teamB?.objectId {
                    if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamBId)") {
                        self.avatarB.setImageWithUrl(url)
                    }
                }
                self.teamBNameLabel.text = isLanguageRu ? teamB.nameRu : teamB.nameEn
            }
            self.teamBScoreLabel.text = game.scoreB?.stringValue ?? "-"
            
            self.titleLabel.text = nil
            if let date = game.date {
                var titleString = GameCell.dateFormatter.stringFromDate(date)
                
                if let venue = isLanguageRu ? game.venueRu : game.venueEn {
                    titleString += " \(venue)"
                }
                
                self.titleLabel.text = titleString
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for view in self.background.subviews {
            if let label = view as? UILabel {
                label.highlightedTextColor = UIColor.mlblLightOrangeColor()
            }
        }
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
        
        if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
            self.teamANameLabel.text = self.language.containsString("ru") ? self.game.teamA?.shortNameRu : self.game.teamA?.shortNameEn
            self.teamBNameLabel.text = self.language.containsString("ru") ? self.game.teamB?.shortNameRu : self.game.teamB?.shortNameEn
        } else {
            self.teamANameLabel.text = self.language.containsString("ru") ? self.game.teamA?.nameRu : self.game.teamA?.nameEn
            self.teamBNameLabel.text = self.language.containsString("ru") ? self.game.teamB?.nameRu : self.game.teamB?.nameEn
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