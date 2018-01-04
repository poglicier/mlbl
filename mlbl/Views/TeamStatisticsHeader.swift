//
//  TeamStatisticsHeader.swift
//  mlbl
//
//  Created by Valentin Shamardin on 09.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

protocol TeamStatisticsHeaderDelegate: class {
    func header(_ header: TeamStatisticsHeader, didScrollTo contentOffset: CGPoint)
}

class TeamStatisticsHeader: UIView {

    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var numberLabel: UILabel!
    @IBOutlet fileprivate var playerLabel: UILabel!
    @IBOutlet fileprivate var timeLabel: UILabel!
    @IBOutlet fileprivate var pointsLabel: UILabel!
    @IBOutlet fileprivate var twoLabel: UILabel!
    @IBOutlet fileprivate var threeLabel: UILabel!
    @IBOutlet fileprivate var oneLabel: UILabel!
    @IBOutlet fileprivate var reboundsOLabel: UILabel!
    @IBOutlet fileprivate var reboundsDLabel: UILabel!
    @IBOutlet fileprivate var reboundsLabel: UILabel!
    @IBOutlet fileprivate var assistsLabel: UILabel!
    @IBOutlet fileprivate var stealsLabel: UILabel!
    @IBOutlet fileprivate var turnoversLabel: UILabel!
    @IBOutlet fileprivate var blocksLabel: UILabel!
    @IBOutlet fileprivate var foulsLabel: UILabel!
    @IBOutlet fileprivate var earnedFoulsLabel: UILabel!
    @IBOutlet fileprivate var plusMinusLabel: UILabel!
    @IBOutlet fileprivate var scrollContentView: UIView!
    @IBOutlet fileprivate var background: UIView!
    @IBOutlet fileprivate var view: UIView!
    @IBOutlet fileprivate var scrollView: UIScrollView!
    
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
        }
    }
    
    // MARK: - Public
    
    weak var delegate: TeamStatisticsHeaderDelegate?
    var contentOffset: CGPoint! {
        didSet {
            self.scrollView.contentOffset = contentOffset
        }
    }
    
    var title: String? = "" {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    // MARK: - Private
    
    fileprivate func initialize() {
        Bundle.main.loadNibNamed(String(describing: self.classForCoder), owner: self, options: [:])
        self.addSubview(self.view)
        self.view.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalTo(0)
        }
        
        self.scrollView.scrollsToTop = false
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize != CGSize.zero {
            self.delegate?.header(self, didScrollTo: scrollView.contentOffset)
        }
    }
}
