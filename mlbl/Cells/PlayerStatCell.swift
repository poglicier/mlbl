//
//  PlayerStatCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 10.08.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class PlayerStatCell: UITableViewCell {
    @IBOutlet fileprivate var background: UIView!
    @IBOutlet fileprivate var avatarView: UIImageView!
    @IBOutlet fileprivate var lastNameLabel: UILabel!
    @IBOutlet fileprivate var firstNameLabel: UILabel!
    @IBOutlet fileprivate var teamLabel: UILabel!
    @IBOutlet fileprivate var valueLabel: UILabel!
    
    var formatter: NumberFormatter!
    var language: String!
    var rank: PlayerRank! {
        didSet {
            if let player = rank.player {
                self.avatarView.image = UIImage(named: "avatarStub\(1 + ((player.objectId as? Int) ?? 1)%3)")
                if let personId = player.objectId {
                    if let url = URL(string: "http://reg.infobasket.ru/Widget/GetPersonPhoto/\(personId)") {
                        self.avatarView.setImageWithUrl(url)
                    }
                }
                
                let isLanguageRu = self.language.contains("ru")
                
                self.firstNameLabel.text = isLanguageRu ? player.firstNameRu : player.firstNameEn
                self.lastNameLabel.text = isLanguageRu ? player.lastNameRu : player.lastNameEn
                self.teamLabel.text = isLanguageRu ? player.team?.shortNameRu : player.team?.shortNameEn
            } else {
                self.firstNameLabel.text = nil
                self.lastNameLabel.text = nil
                self.teamLabel.text = nil
            }
            
            if let res = rank.res {
                if rank.parameter?.name?.contains("время") == true {
                    let seconds = res.intValue
                    self.valueLabel.text = String(format: "\(seconds/60):%02zd", seconds % 60)
                } else {
                    self.valueLabel.text = self.formatter.string(from: res)
                    
                    if rank.parameter?.name?.contains("Точность") == true ||
                        rank.parameter?.name?.contains("коэффициент") == true {
                        self.valueLabel.text! += " %"
                    }
                }
            } else {
                self.valueLabel.text = "0"
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
        
        if let player = rank.player {
            let isLanguageRu = self.language.contains("ru")
            if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
                self.teamLabel.text = isLanguageRu ? player.team?.shortNameRu : player.team?.shortNameEn
            } else {
                self.teamLabel.text = isLanguageRu ? player.team?.nameRu : player.team?.nameEn
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let color = self.background.backgroundColor
        super.setSelected(selected, animated: animated)
        
        if (selected) {
            self.background.backgroundColor = color
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let color = self.background.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        
        if (highlighted) {
            self.background.backgroundColor = color
        }
    }
}
