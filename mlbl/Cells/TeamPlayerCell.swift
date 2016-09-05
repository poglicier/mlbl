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
//            
//            self.setNeedsDisplay()
        }
    }
    
    var isLast = false //{
//        didSet {
//            if oldValue != isLast {
//                self.setNeedsDisplay()
//            }
//        }
//    }
    
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
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
//        self.background.layer.shadowRadius = 1
////        self.background.layer.masksToBounds = true
//        self.background.layer.shadowOffset = CGSizeMake(1, 1)
//        self.background.layer.shadowOpacity = 0.5
//
//        if self.isLast {
//            let path = UIBezierPath(roundedRect: self.background.bounds,
//                                    byRoundingCorners:[.BottomLeft, .BottomRight],
//                                    cornerRadii:CGSizeMake(5, 5))
//            let maskLayer = CAShapeLayer()
//            maskLayer.path = path.CGPath
//            self.background.layer.mask = maskLayer
//            
//            self.background.layer.masksToBounds = true
//            self.background.clipsToBounds = true
//        } else {
//            let shadowFrame = self.background.bounds
//            let shadowPath = UIBezierPath(rect: shadowFrame).CGPath
//            self.background.layer.shadowPath = shadowPath
//
//            self.background.layer.masksToBounds = false
//            self.background.clipsToBounds = false
//        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let isLanguageRu = self.language.containsString("ru")
        if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
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
        } else {
            if var playerName = isLanguageRu ? player.lastNameRu : player.lastNameEn {
                if let firstName = isLanguageRu ? player.firstNameRu : player.firstNameEn {
                        playerName += " \(firstName)"
                }
                
                self.playerLabel.text = "\(playerName)"
            } else {
                self.playerLabel.text = nil
            }
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