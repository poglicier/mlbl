//
//  PlayerCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 28.02.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class PlayerCell: UITableViewCell {

    @IBOutlet private var avatarView: UIImageView!
    
    var player: AnyObject! {
        didSet {
            self.avatarView.image = UIImage(named: "avatarStub\(1+arc4random_uniform(3))")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
