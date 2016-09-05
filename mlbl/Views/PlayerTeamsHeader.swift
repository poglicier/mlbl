//
//  PlayerTeamsHeader.swift
//  mlbl
//
//  Created by Valentin Shamardin on 05.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class PlayerTeamsHeader: UIView {

    @IBOutlet private var view: UIView!
    @IBOutlet private var background: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var seasonLabel: UILabel!
    @IBOutlet private var teamLabel: UILabel!
    
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
            if let _ = self.background {
                self.background.layer.cornerRadius = 5
            }
        }
    }
    
    // MARK: - Private
    
    private func initialize() {
        NSBundle.mainBundle().loadNibNamed(String(self.classForCoder), owner: self, options: [:])
        self.addSubview(self.view)
        self.view.snp_makeConstraints { (make) in
            make.left.top.right.bottom.equalTo(0)
        }
        
        self.titleLabel.text = NSLocalizedString("Teams", comment: "").uppercaseString
        self.seasonLabel.text = NSLocalizedString("Season", comment: "")
        self.teamLabel.text = NSLocalizedString("Team", comment: "")
    }
}