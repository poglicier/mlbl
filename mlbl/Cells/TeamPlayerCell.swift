//
//  TeamPlayerCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 02.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class TeamPlayerCell: UITableViewCell {

    var language: String!
    var color: UIColor? {
        didSet {
            self.background.backgroundColor = color
        }
    }
    
    var player: Player! {
        didSet {
            if let number = player.playerNumber {
                self.numberLabel.text = "\(number)"
            } else {
                self.numberLabel.text = nil
            }
            
            let isLanguageRu = self.language.containsString("ru")
            
            if var playerName = isLanguageRu ? player.lastNameRu : player.lastNameEn {
                if let firstName = isLanguageRu ? player.firstNameRu : player.firstNameEn {
                    if let firstLetter = firstName.characters.first {
                        playerName += " \(firstLetter)."
                    }
                }
                
                self.playerLabel.text = "\(playerName)"
            } else {
                self.playerLabel.text = nil
            }
            
            var position = isLanguageRu ? player.positionShortRu : player.positionShortEn
            if position == nil {
                position = isLanguageRu ? player.positionRu : player.positionEn
                if let _ = position {
                    position = "\(position!.characters.first)"
                }
            }
            self.positionLabel.text = position
            if let height = player.height {
                self.heightLabel.text = "\(height)"
            } else {
                self.heightLabel.text = nil
            }
            if let weight = player.weight {
                self.weightLabel.text = "\(weight)"
            } else {
                self.weightLabel.text = nil
            }
            if let birth = player.birth {
                let ageComponents = NSCalendar.currentCalendar().components(.Year,
                                                                            fromDate:birth,
                                                                            toDate:NSDate(),
                                                                            options:[])
                let age = ageComponents.year
                
                self.ageLabel.text = "\(age)"
            } else {
                self.ageLabel.text = nil
            }
        }
    }
    
    var isLast = false
    
    @IBOutlet private var background: UIView!
    @IBOutlet private var numberLabel: UILabel!
    @IBOutlet private var playerLabel: UILabel!
    @IBOutlet private var positionLabel: UILabel!
    @IBOutlet private var heightLabel: UILabel!
    @IBOutlet private var weightLabel: UILabel!
    @IBOutlet private var ageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        for label in self.background.subviews {
            (label as? UILabel)?.highlightedTextColor = UIColor.mlblLightOrangeColor()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.isLast {
            let path = UIBezierPath(roundedRect: self.background.bounds,
                                    byRoundingCorners:[.BottomLeft, .BottomRight],
                                    cornerRadii:CGSizeMake(5, 5))
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.CGPath
            self.background.layer.mask = maskLayer
            
            self.background.layer.shadowRadius = 1
            self.background.layer.masksToBounds = true
            self.background.layer.shadowOffset = CGSizeMake(1, 1)
            self.background.layer.shadowOpacity = 0.5
            self.background.layer.masksToBounds = false
            self.background.clipsToBounds = false
        } else {
            let path = UIBezierPath()
            path.moveToPoint(CGPointMake(0, 0))
            path.addLineToPoint(CGPointMake(self.background.frame.size.width, 0))
            path.addLineToPoint(CGPointMake(self.background.frame.size.width, self.background.frame.size.height))
            path.addLineToPoint(CGPointMake(0, self.background.frame.size.height))
            path.closePath()
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.CGPath
            self.background.layer.mask = maskLayer
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