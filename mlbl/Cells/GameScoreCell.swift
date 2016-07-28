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
            let isLanguageRu = self.language.containsString("ru")
            
            self.titleLabel.text = nil
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy, hh:mm"
            if let date = game.date {
                var titleString = dateFormatter.stringFromDate(date)
                
                if let venue = isLanguageRu ? game.venueRu : game.venueEn {
                    titleString += " \(venue)"
                }
                self.titleLabel.text = titleString
            }
            
            if let statistics = game.statistics as? Set<GameStatistics> {
                if let statisticsA = (statistics.filter {$0.teamNumber?.integerValue == 1}).first {
                    if let teamA = statisticsA.team {
                        if let teamAId = teamA.objectId {
                            if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamAId)") {
                                self.avatarA.setImageWithUrl(url)
                            }
                        }
                        self.titleA.text = isLanguageRu ? teamA.nameRu : teamA.nameEn
                        self.regionA.text = isLanguageRu ? teamA.regionNameRu : teamA.regionNameEn
                    }
                }
                
                if let statisticsB = (statistics.filter {$0.teamNumber?.integerValue == 2}).first {
                    if let teamB = statisticsB.team {
                        if let teamBId = teamB.objectId {
                            if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamBId)") {
                                self.avatarB.setImageWithUrl(url)
                            }
                        }
                        self.titleB.text = isLanguageRu ? teamB.nameRu : teamB.nameEn
                        self.regionB.text = isLanguageRu ? teamB.regionNameRu : teamB.regionNameEn
                    }
                }
            }
            self.scoreA.text = game.scoreA?.stringValue ?? "-"
            self.scoreB.text = game.scoreB?.stringValue ?? "-"
            
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
        
        if let statistics = game.statistics as? Set<GameStatistics> {
            let isLanguageRu = self.language.containsString("ru")
            
            if let statisticsA = (statistics.filter {$0.teamNumber?.integerValue == 1}).first {
                if let teamA = statisticsA.team {
                    if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
                      self.titleA.text = isLanguageRu ? teamA.nameRu : teamA.nameEn
                    } else {
                        self.titleA.text = isLanguageRu ? teamA.nameRu : teamA.nameEn
                    }
                }
            }
            
            if let statisticsB = (statistics.filter {$0.teamNumber?.integerValue == 2}).first {
                if let teamB = statisticsB.team {
                    if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
                        self.titleB.text = isLanguageRu ? teamB.shortNameRu : teamB.shortNameEn
                    } else {
                        self.titleB.text = isLanguageRu ? teamB.nameRu : teamB.nameEn
                    }
                }
            }
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