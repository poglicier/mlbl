//
//  GameScoreCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 07.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class GameScoreCell: UITableViewCell {
    @IBOutlet private var background: UIView!
    @IBOutlet private var bottomGrayView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var avatarA: UIImageView!
    @IBOutlet private var titleA: UILabel!
    @IBOutlet private var scoreA: UILabel!
    @IBOutlet private var regionA: UILabel!
    @IBOutlet private var avatarB: UIImageView!
    @IBOutlet private var titleB: UILabel!
    @IBOutlet private var scoreB: UILabel!
    @IBOutlet private var regionB: UILabel!
    @IBOutlet private var collectionView: UICollectionView!
    
    private var scoreByPeriods: [(Int, Int)]!
    
    var language: String!
    
    var game: Game! {
        didSet {
            self.titleLabel.text = nil
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy, hh:mm"
            if let date = game.date {
                var titleString = dateFormatter.stringFromDate(date)
                
                if let venue = game.venueRu {
                    titleString += " \(venue)"
                    self.titleLabel.text = titleString
                }
            }
            
            if let teamA = game.teamA {
                if let teamAId = game.teamA?.objectId {
                    if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamAId)") {
                        self.avatarA.setImageWithUrl(url)
                    }
                }
                self.titleA.text = self.language.containsString("ru") ? teamA.nameRu : teamA.nameEn
            }
            self.scoreA.text = game.scoreA?.stringValue ?? "-"
            
            if let teamB = game.teamB {
                if let teamBId = game.teamB?.objectId {
                    if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamBId)") {
                        self.avatarB.setImageWithUrl(url)
                    }
                }
                self.titleB.text = self.language.containsString("ru") ? teamB.nameRu : teamB.nameEn
            }
            
            
            self.regionA.text = self.language.containsString("ru") ? game.teamA?.regionNameRu : game.teamA?.regionNameEn
            self.scoreA.text = game.scoreA?.stringValue
            
            self.regionB.text = self.language.containsString("ru") ? game.teamB?.regionNameRu : game.teamA?.regionNameEn
            self.scoreB.text = game.scoreB?.stringValue
            
            if let teamAId = game.teamA?.objectId {
                if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamAId)") {
                    self.avatarA.setImageWithUrl(url)
                }
            }
            
            if let teamBId = game.teamB?.objectId {
                if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamBId)") {
                    self.avatarB.setImageWithUrl(url)
                }
            }
            
            self.scoreByPeriods = [(Int, Int)]()
            if let periodScores = game.scoreByPeriods?.componentsSeparatedByString(", ") {
                for periodScore in periodScores {
                    let scores = periodScore.componentsSeparatedByString(":")
                    if let score1 = scores.first {
                        if let score2 = scores.last {
                            self.scoreByPeriods.append((score1.integer(), score2.integer()))
                        }
                    }
                }
            }
            self.collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.scrollsToTop = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath(roundedRect:self.bottomGrayView.bounds, byRoundingCorners:[.BottomRight, .BottomLeft], cornerRadii: CGSizeMake(5, 5))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.CGPath
        self.bottomGrayView.layer.mask = maskLayer
        
        self.background.layer.cornerRadius = 5
        self.background.layer.shadowRadius = 1
        self.background.layer.masksToBounds = true
        self.background.layer.shadowOffset = CGSizeMake(1, 1)
        self.background.layer.shadowOpacity = 0.5
        self.background.layer.masksToBounds = false
        self.background.clipsToBounds = false
        
        if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
            self.titleA.text = self.language.containsString("ru") ? self.game.teamA?.shortNameRu : self.game.teamA?.shortNameEn
            self.titleB.text = self.language.containsString("ru") ? self.game.teamB?.shortNameRu : self.game.teamB?.shortNameEn
        } else {
            self.titleA.text = self.language.containsString("ru") ? self.game.teamA?.nameRu : self.game.teamA?.nameEn
            self.titleB.text = self.language.containsString("ru") ? self.game.teamB?.nameRu : self.game.teamB?.nameEn
        }
    }
}

extension GameScoreCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.scoreByPeriods.count ?? 0) + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("periodCell", forIndexPath: indexPath) as! PeriodCell
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let periodCell = cell as! PeriodCell
        let count = self.collectionView.numberOfItemsInSection(0)
        
        if indexPath.row == count - 1 {
            periodCell.periodLabel.text = NSLocalizedString("Total", comment: "")
            periodCell.teamALabel.font = UIFont.boldSystemFontOfSize(16)
            periodCell.teamBLabel.font = UIFont.boldSystemFontOfSize(16)
            
            var teamAResult: Int = 0
            var teamBResult: Int = 0
            for scoreOfPeriod in self.scoreByPeriods {
                teamAResult += scoreOfPeriod.0
                teamBResult += scoreOfPeriod.1
            }
            periodCell.teamALabel.text = "\(teamAResult)"
            periodCell.teamBLabel.text = "\(teamBResult)"
        } else {
            periodCell.teamALabel.font = UIFont.systemFontOfSize(16)
            periodCell.teamBLabel.font = UIFont.systemFontOfSize(16)
            
            periodCell.teamALabel.text = "\(self.scoreByPeriods[indexPath.row].0)"
            periodCell.teamBLabel.text = "\(self.scoreByPeriods[indexPath.row].1)"
            
            switch indexPath.row {
            case 0:
                periodCell.periodLabel.text = "I"
            case 1:
                periodCell.periodLabel.text = "II"
            case 2:
                periodCell.periodLabel.text = "III"
            case 3:
                periodCell.periodLabel.text = "IV"
            case 4:
                periodCell.periodLabel.text = "OT"
            default:
                periodCell.periodLabel.text = "OT\(indexPath.row - 3)"
            }
        }
    }
}