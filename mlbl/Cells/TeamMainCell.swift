//
//  TeamMainCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 01.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class TeamMainCell: UITableViewCell {
    @IBOutlet private var background: UIView!
    @IBOutlet private var avatar: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var cityLabel: UILabel!

    var language: String!
    
    var team: Team! {
        didSet {
            let isLanguageRu = self.language.containsString("ru")
            
            self.avatar.image = UIImage(named: "teamStub")
            
            if let teamId = team.objectId {
                if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamId)") {
                    self.avatar.setImageWithUrl(url)
                }
            }
            self.nameLabel.text = isLanguageRu ? team.nameRu : team.nameEn
            
            let region = isLanguageRu ? team.regionNameRu : team.regionNameEn
            if region?.characters.count ?? 0 > 0 {
                self.cityLabel.text = "(\(region!))"
            } else {
                self.cityLabel.text = ""
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
    }
}