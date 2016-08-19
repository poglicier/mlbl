//
//  ParameterCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 10.08.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class ParameterCell: UICollectionViewCell {
    
    @IBOutlet private var label: UILabel!
    
    var parameter: StatParameter! {
        didSet {
            self.label.text = parameter.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.label.backgroundColor = UIColor.whiteColor()
        self.label.layer.cornerRadius = self.label.frame.size.height/2
        self.label.layer.masksToBounds = true
    }
    
    // MARK: - Public
    
    var isParameterSelected: Bool! {
        didSet {
            self.label.textColor = (isParameterSelected == true) ? UIColor.whiteColor() : UIColor.blackColor()
            self.label.backgroundColor = (isParameterSelected == true) ? UIColor.mlblLightOrangeColor() : UIColor.whiteColor()
        }
    }
}