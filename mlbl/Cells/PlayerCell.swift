//
//  PlayerCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 28.02.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class PlayerCell: UITableViewCell {
    @IBOutlet private var background: UIView!
    @IBOutlet private var avatarView: UIImageView!
    @IBOutlet private var teamAvatarView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var dateTitleLabel: UILabel!
    @IBOutlet private var dateValueLabel: UILabel!
    @IBOutlet private var heightTitleLabel: UILabel!
    @IBOutlet private var heightValueLabel: UILabel!
    @IBOutlet private var weightTitleLabel: UILabel!
    @IBOutlet private var weightValueLabel: UILabel!
    @IBOutlet private var teamLabel: UILabel!
    @IBOutlet private var positionLabel: UILabel!
    
    static private var dateFormatter: NSDateFormatter = {
        let res = NSDateFormatter()
        res.dateFormat = "dd.MM.yyyy"
        return res
    }()
    
    var language: String!
    var player: Player! {
        didSet {
            self.avatarView.image = UIImage(named: "avatarStub\(1 + ((player.objectId as? Int) ?? 1)%3)")
            if let personId = player.objectId {
                if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetPersonPhoto/\(personId)") {
                    self.avatarView.setImageWithUrl(url)
                }
            }
            
            let isLanguageRu = self.language.containsString("ru")
            
            let firstName = isLanguageRu ? player.firstNameRu : player.firstNameEn
            let lastName = isLanguageRu ? player.lastNameRu : player.lastNameEn
            
            if lastName != nil {
                if firstName != nil {
                    self.nameLabel.text = lastName! + " " + firstName!
                } else {
                    self.nameLabel.text = lastName
                }
            } else {
                self.nameLabel.text = "-"
            }
            
            self.positionLabel.text = isLanguageRu ? player.positionShortRu : player.positionShortEn
            
            if let date = player.birth {
                self.dateValueLabel.text = PlayerCell.dateFormatter.stringFromDate(date)
            } else {
                self.dateValueLabel.text = "-"
            }
            
            if let height = player.height {
                self.heightValueLabel.text = "\(height)" + " " + NSLocalizedString("cm", comment: "")
            } else {
                self.heightValueLabel.text = "-"
            }
            
            if let weight = player.weight {
                self.weightValueLabel.text = "\(weight)" + " " + NSLocalizedString("kg", comment: "")
            } else {
                self.weightValueLabel.text = "-"
            }
            
            self.teamLabel.text = isLanguageRu ? player.team?.shortNameRu : player.team?.shortNameEn
            
            self.teamAvatarView.image = UIImage(named: "teamStub")
            if let teamId = player.team?.objectId {
                if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamId)") {
                    self.teamAvatarView.setImageWithUrl(url)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.dateTitleLabel.text = NSLocalizedString("Date", comment: "") + ":"
        self.heightTitleLabel.text = NSLocalizedString("Height", comment: "") + ":"
        self.weightTitleLabel.text = NSLocalizedString("Weight", comment: "") + ":"
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
            self.teamLabel.text = isLanguageRu ? self.player.team?.shortNameRu : self.player.team?.shortNameEn
            self.positionLabel.text = isLanguageRu ? self.player.positionShortRu : self.player.positionShortEn
        } else {
            self.teamLabel.text = isLanguageRu ? self.player.team?.nameRu : self.player.team?.nameEn
            self.positionLabel.text = isLanguageRu ? self.player.positionRu : self.player.positionEn
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