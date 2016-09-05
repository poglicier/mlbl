//
//  TeamPlayersHeader.swift
//  mlbl
//
//  Created by Valentin Shamardin on 02.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class TeamPlayersHeader: UIView {

    @IBOutlet private var view: UIView!
    @IBOutlet private var background: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var numberLabel: UILabel!
    @IBOutlet private var playerLabel: UILabel!
    @IBOutlet private var positionLabel: UILabel!
    @IBOutlet private var heghtLabel: UILabel!
    @IBOutlet private var weightLabel: UILabel!
    @IBOutlet private var ageLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if let _ = self.background {
            self.background.layer.cornerRadius = 5
            
//            self.background.layer.shadowRadius = 1
//            self.background.layer.masksToBounds = true
//            self.background.layer.shadowOffset = CGSizeMake(1, 1)
//            self.background.layer.shadowOpacity = 0.3
//            self.background.layer.masksToBounds = false
//            self.background.clipsToBounds = false
        }
    }
    
    // MARK: - Private
    
    private func initialize() {
        NSBundle.mainBundle().loadNibNamed(String(self.classForCoder), owner: self, options: [:])
        self.addSubview(self.view)
        self.view.snp_makeConstraints { (make) in
            make.left.top.right.bottom.equalTo(0)
        }
        
        self.titleLabel.text = NSLocalizedString("Roster", comment: "").uppercaseString
        self.numberLabel.text = NSLocalizedString("Number", comment: "")
        self.playerLabel.text = NSLocalizedString("Player", comment: "")
        self.positionLabel.text = NSLocalizedString("Position acronym", comment: "")
        self.heghtLabel.text = NSLocalizedString("Height acronym", comment: "")
        self.weightLabel.text = NSLocalizedString("Weight acronym", comment: "")
        self.ageLabel.text = NSLocalizedString("Age acronym", comment: "")
    }
}