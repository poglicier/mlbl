//
//  GameCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 05.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class GameCell: UITableViewCell {

    @IBOutlet fileprivate var background: UIView!
    @IBOutlet fileprivate var avatarA: UIImageView!
    @IBOutlet fileprivate var avatarB: UIImageView!
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var statusLabel: UILabel!
    @IBOutlet fileprivate var teamAScoreLabel: UILabel!
    @IBOutlet fileprivate var teamBScoreLabel: UILabel!
    @IBOutlet fileprivate var teamANameLabel: UILabel!
    @IBOutlet fileprivate var teamBNameLabel: UILabel!
    @IBOutlet fileprivate var separatorLine: UIView!
    
    static fileprivate var dateFormatter: DateFormatter = {
        let res = DateFormatter()
        res.dateFormat = "dd MMMM yyyy, HH:mm"
        return res
    }()
    
    var language: String!
    
    var game: Game! {
        didSet {
            let isLanguageRu = self.language.contains("ru")
            
            self.avatarA.image = UIImage(named: "teamStub")
            self.avatarB.image = UIImage(named: "teamStub")
            
            if let teamAId = game.teamAId {
                if let url = URL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamAId)") {
                    self.avatarA.setImageWithUrl(url)
                }
            }
            self.teamANameLabel.text = isLanguageRu ? game.teamNameAru : game.teamNameAen

            if let teamBId = game.teamBId {
                if let url = URL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamBId)") {
                    self.avatarB.setImageWithUrl(url)
                }
            }
            self.teamBNameLabel.text = isLanguageRu ? game.teamNameBru : game.teamNameBen
            
            self.teamAScoreLabel.text = game.scoreA?.stringValue ?? "-"
            self.teamBScoreLabel.text = game.scoreB?.stringValue ?? "-"
            
            self.titleLabel.text = nil
            if let date = game.date {
                var titleString = GameCell.dateFormatter.string(from: date as Date)
                
                if let venue = isLanguageRu ? game.venueRu : game.venueEn {
                    titleString += " \(venue)"
                }
                
                self.titleLabel.text = titleString
            }
            
            if let status = game.status {
                self.statusLabel.isHidden = false
                let statusStr = "Game Status \(status)"
                self.statusLabel.text = NSLocalizedString(statusStr, comment: "")
            } else {
                self.statusLabel.isHidden = true
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
        self.background.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.background.layer.shadowOpacity = 0.5
        self.background.layer.masksToBounds = false
        self.background.clipsToBounds = false
        
        let isLanguageRu = self.language.contains("ru")
        if UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portrait {
            self.teamANameLabel.text = isLanguageRu ? game.shortTeamNameAru : game.shortTeamNameAen
            self.teamBNameLabel.text = isLanguageRu ? game.shortTeamNameBru : game.shortTeamNameBen
        } else {
            self.teamANameLabel.text = isLanguageRu ? game.teamNameAru : game.teamNameAen
            self.teamBNameLabel.text = isLanguageRu ? game.teamNameBru : game.teamNameBen
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = self.background.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if (selected) {
            self.background.backgroundColor = color
        }
        
        self.separatorLine.backgroundColor = UIColor.mlblLightOrangeColor()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = self.background.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        
        if (highlighted) {
            self.background.backgroundColor = color
        }
        
        self.separatorLine.backgroundColor = UIColor.mlblLightOrangeColor()
    }
}
