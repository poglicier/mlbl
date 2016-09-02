//
//  TeamGamesHeader.swift
//  mlbl
//
//  Created by Valentin Shamardin on 03.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class TeamGamesHeader: UIView {
    
    @IBOutlet private var view: UIView!
    @IBOutlet private var background: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var opponentLabel: UILabel!
    @IBOutlet private var scoreLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.text = NSLocalizedString("Games", comment: "").uppercaseString
        self.dateLabel.text = NSLocalizedString("Date", comment: "")
        self.opponentLabel.text = NSLocalizedString("Opponent", comment: "")
        self.scoreLabel.text = NSLocalizedString("Score", comment: "")
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if let _ = self.background {
            let path = UIBezierPath(roundedRect: self.background.bounds,
                                    byRoundingCorners:[.TopLeft, .TopRight],
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
        }
    }
    
    // MARK: - Private
    
    private func initialize() {
        NSBundle.mainBundle().loadNibNamed(String(self.classForCoder), owner: self, options: [:])
        self.addSubview(self.view)
        self.view.snp_makeConstraints { (make) in
            make.left.top.right.bottom.equalTo(0)
        }
    }
}