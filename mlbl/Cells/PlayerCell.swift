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
    
    var player: AnyObject! {
        didSet {
            self.avatarView.image = UIImage(named: "avatarStub\(1+arc4random_uniform(3))")
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
