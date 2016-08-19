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
    @IBOutlet private var separatorLine: UIView!
    
    static private var dateFormatter: NSDateFormatter = {
        let res = NSDateFormatter()
        res.dateFormat = "dd MMMM yyyy, HH:mm"
        return res
    }()
    
    var language: String!
    
    var game: Game! {
        didSet {
            let isLanguageRu = self.language.containsString("ru")
            
            self.avatarA.image = UIImage(named: "teamStub")
            self.avatarB.image = UIImage(named: "teamStub")
            
            if let teamAId = game.teamAId {
                if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamAId)") {
                    self.avatarA.setImageWithUrl(url)
                }
            }
            self.teamANameLabel.text = isLanguageRu ? game.teamNameAru : game.teamNameAen

            if let teamBId = game.teamBId {
                if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamBId)") {
                    self.avatarB.setImageWithUrl(url)
                }
            }
            self.teamBNameLabel.text = isLanguageRu ? game.teamNameBru : game.teamNameBen
            
            self.teamAScoreLabel.text = game.scoreA?.stringValue ?? "-"
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
        
        let isLanguageRu = self.language.containsString("ru")
        if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
            self.teamANameLabel.text = isLanguageRu ? game.shortTeamNameAru : game.shortTeamNameAen
            self.teamBNameLabel.text = isLanguageRu ? game.shortTeamNameBru : game.shortTeamNameBen
        } else {
            self.teamANameLabel.text = isLanguageRu ? game.teamNameAru : game.teamNameAen
            self.teamBNameLabel.text = isLanguageRu ? game.teamNameBru : game.teamNameBen
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        let color = self.background.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if (selected) {
            self.background.backgroundColor = color
        }
        
        self.separatorLine.backgroundColor = UIColor.mlblLightOrangeColor()
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let color = self.background.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        
        if (highlighted) {
            self.background.backgroundColor = color
        }
        
        self.separatorLine.backgroundColor = UIColor.mlblLightOrangeColor()
    }
}