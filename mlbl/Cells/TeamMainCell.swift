//
//  TeamMainCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 01.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class TeamMainCell: UITableViewCell {
    @IBOutlet fileprivate var background: UIView!
    @IBOutlet fileprivate var avatar: UIImageView!
    @IBOutlet fileprivate var nameLabel: UILabel!
    @IBOutlet fileprivate var cityLabel: UILabel!

    var language: String!
    
    var team: Team! {
        didSet {
            let isLanguageRu = self.language.contains("ru")
            
            self.avatar.image = UIImage(named: "teamStub")
            
            if let teamId = team.objectId {
                if let url = URL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamId)") {
                    self.avatar.setImageWithUrl(url)
                }
            }
            self.nameLabel.text = isLanguageRu ? team.nameRu : team.nameEn
            
            let region = isLanguageRu ? team.regionNameRu : team.regionNameEn
            if region?.count ?? 0 > 0 {
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
        self.background.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.background.layer.shadowOpacity = 0.5
        self.background.layer.masksToBounds = false
        self.background.clipsToBounds = false
    }
}
