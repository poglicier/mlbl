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
            
            let isLanguageRu = self.language.contains("ru")
            
            if var playerName = isLanguageRu ? player.lastNameRu : player.lastNameEn {
                if let firstName = isLanguageRu ? player.firstNameRu : player.firstNameEn {
                    if let firstLetter = firstName[0] {
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
                    position = "\(position![0] ?? "")"
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
                let ageComponents = (Calendar.current as NSCalendar).components(.year,
                                                                            from:birth as Date,
                                                                            to:Date(),
                                                                            options:[])
                if let age = ageComponents.year {
                    self.ageLabel.text = "\(age)"
                } else {
                    self.ageLabel.text = nil
                }
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
    
    @IBOutlet fileprivate var background: UIView!
    @IBOutlet fileprivate var numberLabel: UILabel!
    @IBOutlet fileprivate var playerLabel: UILabel!
    @IBOutlet fileprivate var positionLabel: UILabel!
    @IBOutlet fileprivate var heightLabel: UILabel!
    @IBOutlet fileprivate var weightLabel: UILabel!
    @IBOutlet fileprivate var ageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
                
        for label in self.background.subviews {
            (label as? UILabel)?.highlightedTextColor = UIColor.mlblLightOrangeColor()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
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
        
        let isLanguageRu = self.language.contains("ru")
        if UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portrait {
            if var playerName = isLanguageRu ? player.lastNameRu : player.lastNameEn {
                if let firstName = isLanguageRu ? player.firstNameRu : player.firstNameEn {
                    if let firstLetter = firstName[0] {
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
