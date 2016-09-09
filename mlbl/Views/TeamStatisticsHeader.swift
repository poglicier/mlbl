//
//  TeamStatisticsHeader.swift
//  mlbl
//
//  Created by Valentin Shamardin on 09.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

protocol TeamStatisticsHeaderDelegate {
    func header(header: TeamStatisticsHeader, didScrollTo contentOffset: CGPoint)
}

class TeamStatisticsHeader: UIView {

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var numberLabel: UILabel!
    @IBOutlet private var playerLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    @IBOutlet private var pointsLabel: UILabel!
    @IBOutlet private var twoLabel: UILabel!
    @IBOutlet private var threeLabel: UILabel!
    @IBOutlet private var oneLabel: UILabel!
    @IBOutlet private var reboundsOLabel: UILabel!
    @IBOutlet private var reboundsDLabel: UILabel!
    @IBOutlet private var reboundsLabel: UILabel!
    @IBOutlet private var assistsLabel: UILabel!
    @IBOutlet private var stealsLabel: UILabel!
    @IBOutlet private var turnoversLabel: UILabel!
    @IBOutlet private var blocksLabel: UILabel!
    @IBOutlet private var foulsLabel: UILabel!
    @IBOutlet private var earnedFoulsLabel: UILabel!
    @IBOutlet private var plusMinusLabel: UILabel!
    @IBOutlet private var scrollContentView: UIView!
    @IBOutlet private var background: UIView!
    @IBOutlet private var view: UIView!
    @IBOutlet private var scrollView: UIScrollView!
    
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
        }
    }
    
    // MARK: - Public
    
    var delegate: TeamStatisticsHeaderDelegate?
    var contentOffset = CGPointZero {
        didSet {
            self.scrollView.contentOffset = contentOffset
        }
    }
    
    // MARK: - Private
    
    private func initialize() {
        NSBundle.mainBundle().loadNibNamed(String(self.classForCoder), owner: self, options: [:])
        self.addSubview(self.view)
        self.view.snp_makeConstraints { (make) in
            make.left.top.right.bottom.equalTo(0)
        }
        
        self.titleLabel.text = NSLocalizedString("Team statistics", comment: "").uppercaseString
        self.scrollView.scrollsToTop = false
        self.scrollView.delegate = self
        self.numberLabel.text = NSLocalizedString("Number", comment: "")
        self.playerLabel.text = NSLocalizedString("Player", comment: "")
        self.timeLabel.text = NSLocalizedString("Time", comment: "")
        self.pointsLabel.text = NSLocalizedString("Points", comment: "")
        self.twoLabel.text = NSLocalizedString("Two pts", comment: "")
        self.threeLabel.text = NSLocalizedString("Three pts", comment: "")
        self.oneLabel.text = NSLocalizedString("One pts", comment: "")
        self.reboundsOLabel.text = NSLocalizedString("Rebounds offensive", comment: "")
        self.reboundsDLabel.text = NSLocalizedString("Rebounds defensive", comment: "")
        self.reboundsLabel.text = NSLocalizedString("Rebounds", comment: "")
        self.assistsLabel.text = NSLocalizedString("Assists", comment: "")
        self.stealsLabel.text = NSLocalizedString("Steals", comment: "")
        self.turnoversLabel.text = NSLocalizedString("Turnovers", comment: "")
        self.blocksLabel.text = NSLocalizedString("Blockshots", comment: "")
        self.foulsLabel.text = NSLocalizedString("Fouls", comment: "")
        self.earnedFoulsLabel.text = NSLocalizedString("Earned fouls", comment: "")
        self.plusMinusLabel.text = "+/-"
    }
}

extension TeamStatisticsHeader: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.delegate?.header(self, didScrollTo: scrollView.contentOffset)
    }
}