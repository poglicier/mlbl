//
//  PlayerGamesCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 05.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class PlayerGamesCell: UITableViewCell {
    
    @IBOutlet fileprivate var background: UIView!
    @IBOutlet fileprivate var hatBackground: UIView!
    @IBOutlet fileprivate var totalBackground: UIView!
    @IBOutlet fileprivate var percentBackground: UIView!
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var guestLabel: UILabel!
    @IBOutlet fileprivate var hostLabel: UILabel!
    @IBOutlet fileprivate var totalLabel: UILabel!
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
    @IBOutlet fileprivate var scrollView: UIScrollView!
    
    fileprivate let fontSize: CGFloat = 15
    fileprivate var addedSubviews = [UIView]()
    
    var language: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.text = NSLocalizedString("Games", comment: "").uppercased()
        self.scrollView.scrollsToTop = false
        self.hostLabel.text = NSLocalizedString("Host", comment: "")
        self.guestLabel.text = NSLocalizedString("Guest", comment: "")
        self.totalLabel.text = NSLocalizedString("Average", comment: "").uppercased()
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.background.layer.cornerRadius = 5
        self.background.layer.shadowRadius = 1
        self.background.layer.masksToBounds = true
        self.background.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.background.layer.shadowOpacity = 0.5
        self.background.layer.masksToBounds = false
        self.background.clipsToBounds = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.addedSubviews.forEach { $0.removeFromSuperview() }
        self.addedSubviews = [UIView]()
    }
}
