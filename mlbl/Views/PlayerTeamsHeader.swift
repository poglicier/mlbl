//
//  PlayerTeamsHeader.swift
//  mlbl
//
//  Created by Valentin Shamardin on 05.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class PlayerTeamsHeader: UIView {

    @IBOutlet fileprivate var view: UIView!
    @IBOutlet fileprivate var background: UIView!
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var seasonLabel: UILabel!
    @IBOutlet fileprivate var teamLabel: UILabel!
    
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
            if let _ = self.background {
                self.background.layer.cornerRadius = 5
            }
        }
    }
    
    // MARK: - Private
    
    fileprivate func initialize() {
        Bundle.main.loadNibNamed(String(describing: self.classForCoder), owner: self, options: [:])
        self.addSubview(self.view)
        self.view.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalTo(0)
        }
        
        self.titleLabel.text = NSLocalizedString("Teams", comment: "").uppercased()
        self.seasonLabel.text = NSLocalizedString("Season", comment: "")
        self.teamLabel.text = NSLocalizedString("Team", comment: "")
    }
}
