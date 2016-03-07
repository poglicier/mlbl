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
    
    var game: Game! {
        didSet {
            
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
