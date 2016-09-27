//
//  TeamGamesHeader.swift
//  mlbl
//
//  Created by Valentin Shamardin on 03.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class TeamGamesHeader: UIView {
    
    @IBOutlet fileprivate var view: UIView!
    @IBOutlet fileprivate var background: UIView!
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var dateLabel: UILabel!
    @IBOutlet fileprivate var opponentLabel: UILabel!
    @IBOutlet fileprivate var scoreLabel: UILabel!
    
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
                
//                self.background.layer.shadowRadius = 1
//                self.background.layer.masksToBounds = true
//                self.background.layer.shadowOffset = CGSizeMake(1, 1)
//                self.background.layer.shadowOpacity = 0.5
//                self.background.layer.masksToBounds = false
//                self.background.clipsToBounds = false
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
        
        self.titleLabel.text = NSLocalizedString("Games", comment: "").uppercased()
        self.dateLabel.text = NSLocalizedString("Date", comment: "")
        self.opponentLabel.text = NSLocalizedString("Opponent", comment: "")
        self.scoreLabel.text = NSLocalizedString("Score", comment: "")
    }
}
