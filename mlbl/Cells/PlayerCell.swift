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
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var dateTitleLabel: UILabel!
    @IBOutlet private var dateValueLabel: UILabel!
    @IBOutlet private var heightTitleLabel: UILabel!
    @IBOutlet private var heightValueLabel: UILabel!
    @IBOutlet private var weightTitleLabel: UILabel!
    @IBOutlet private var weightValueLabel: UILabel!
    
    static private var dateFormatter: NSDateFormatter = {
        let res = NSDateFormatter()
        res.dateFormat = "dd.MM.yyyy"
        return res
    }()
    
    var language: String!
    var player: Player! {
        didSet {
            self.avatarView.image = UIImage(named: "avatarStub\(1+arc4random_uniform(3))")
            
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