//
//  ParameterCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 10.08.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class ParameterCell: UICollectionViewCell {
    
    @IBOutlet fileprivate var label: UILabel!
    
    var parameter: StatParameter! {
        didSet {
            self.label.text = parameter.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.label.backgroundColor = UIColor.white
        self.label.layer.masksToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.label.layer.cornerRadius = self.label.frame.size.height/2
    }
    
    // MARK: - Public
    
    var isParameterSelected: Bool! {
        didSet {
            self.label.textColor = (isParameterSelected == true) ? UIColor.white : UIColor.black
            self.label.backgroundColor = (isParameterSelected == true) ? UIColor.mlblLightOrangeColor() : UIColor.white
        }
    }
}
