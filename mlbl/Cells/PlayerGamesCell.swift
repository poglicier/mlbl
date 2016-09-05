//
//  PlayerGamesCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 05.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class PlayerGamesCell: UITableViewCell {
    
    @IBOutlet private var background: UIView!
    @IBOutlet private var hatBackground: UIView!
    @IBOutlet private var totalBackground: UIView!
    @IBOutlet private var percentBackground: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var guestLabel: UILabel!
    @IBOutlet private var hostLabel: UILabel!
    @IBOutlet private var totalLabel: UILabel!
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
    @IBOutlet private var scrollView: UIScrollView!
    
    private let fontSize: CGFloat = 15
    private var addedSubviews = [UIView]()
    
    var language: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.text = NSLocalizedString("Games", comment: "").uppercaseString
        self.scrollView.scrollsToTop = false
        self.hostLabel.text = NSLocalizedString("Host", comment: "")
        self.guestLabel.text = NSLocalizedString("Guest", comment: "")
        self.totalLabel.text = NSLocalizedString("Average", comment: "").uppercaseString
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
        self.background.layer.shadowOffset = CGSizeMake(1, 1)
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