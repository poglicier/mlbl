//
//  TeamPlayersHeader.swift
//  mlbl
//
//  Created by Valentin Shamardin on 02.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class TeamPlayersHeader: UIView {

    @IBOutlet fileprivate var view: UIView!
    @IBOutlet fileprivate var background: UIView!
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var numberLabel: UILabel!
    @IBOutlet fileprivate var playerLabel: UILabel!
    @IBOutlet fileprivate var positionLabel: UILabel!
    @IBOutlet fileprivate var heghtLabel: UILabel!
    @IBOutlet fileprivate var weightLabel: UILabel!
    @IBOutlet fileprivate var ageLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
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
    
    fileprivate func initialize() {
        Bundle.main.loadNibNamed(String(describing: self.classForCoder), owner: self, options: [:])
        self.addSubview(self.view)
        self.view.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalTo(0)
        }
        
        self.titleLabel.text = NSLocalizedString("Roster", comment: "").uppercased()
        self.numberLabel.text = NSLocalizedString("Number", comment: "")
        self.playerLabel.text = NSLocalizedString("Player", comment: "")
        self.positionLabel.text = NSLocalizedString("Position acronym", comment: "")
        self.heghtLabel.text = NSLocalizedString("Height acronym", comment: "")
        self.weightLabel.text = NSLocalizedString("Weight acronym", comment: "")
        self.ageLabel.text = NSLocalizedString("Age acronym", comment: "")
    }
}
