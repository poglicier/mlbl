//
//  GameScoreCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 07.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class GameScoreCell: UITableViewCell {
    @IBOutlet fileprivate var background: UIView!
    @IBOutlet fileprivate var bottomGrayView: UIView!
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var avatarA: UIImageView!
    @IBOutlet fileprivate var titleA: UILabel!
    @IBOutlet fileprivate var scoreA: UILabel!
    @IBOutlet fileprivate var regionA: UILabel!
    @IBOutlet fileprivate var avatarB: UIImageView!
    @IBOutlet fileprivate var titleB: UILabel!
    @IBOutlet fileprivate var scoreB: UILabel!
    @IBOutlet fileprivate var regionB: UILabel!
    @IBOutlet fileprivate var collectionView: UICollectionView!
    
    fileprivate var scoreByPeriods: [(Int, Int)]!
    
    var language: String!
    
    var game: Game! {
        didSet {
            let isLanguageRu = self.language.contains("ru")
            
            self.titleLabel.text = nil
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy, HH:mm"
            if let date = game.date {
                var titleString = dateFormatter.string(from: date as Date)
                
                if let venue = isLanguageRu ? game.venueRu : game.venueEn {
                    titleString += " \(venue)"
                }
                self.titleLabel.text = titleString
            }
            
            self.titleA.text = nil
            self.regionA.text = nil
            self.titleB.text = nil
            self.regionB.text = nil
            
            if let statistics = game.statistics as? Set<GameStatistics> {
                if let statisticsA = (statistics.filter {$0.teamNumber?.intValue == 1 && $0.player == nil}).first {
                    if let teamA = statisticsA.team {
                        if let teamAId = teamA.objectId {
                            if let url = URL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamAId)") {
                                self.avatarA.setImageWithUrl(url)
                            }
                        }
                        self.titleA.text = isLanguageRu ? teamA.nameRu : teamA.nameEn
                        self.regionA.text = isLanguageRu ? teamA.regionNameRu : teamA.regionNameEn
                    }
                }
                
                if let statisticsB = (statistics.filter {$0.teamNumber?.intValue == 2 && $0.player == nil}).first {
                    if let teamB = statisticsB.team {
                        if let teamBId = teamB.objectId {
                            if let url = URL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamBId)") {
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
            if let periodScores = game.scoreByPeriods?.components(separatedBy: ", ") {
                for periodScore in periodScores {
                    let scores = periodScore.components(separatedBy: ":")
                    if let score1 = scores.first {
                        if let score2 = scores.last {
                            self.scoreByPeriods.append((score1.integer(), score2.integer()))
                        }
                    }
                }
            }
            self.collectionView.reloadData()
            
             self.setNeedsLayout()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.scrollsToTop = false
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let path = UIBezierPath(roundedRect:self.bottomGrayView.bounds, byRoundingCorners:[.bottomRight, .bottomLeft], cornerRadii: CGSize(width: 5, height: 5))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.bottomGrayView.layer.mask = maskLayer
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
        
        if let statistics = game.statistics as? Set<GameStatistics> {
            let isLanguageRu = self.language.contains("ru")
            
            if let statisticsA = (statistics.filter {$0.teamNumber?.intValue == 1}).first {
                if let teamA = statisticsA.team {
                    if UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portrait {
                      self.titleA.text = isLanguageRu ? teamA.nameRu : teamA.nameEn
                    } else {
                        self.titleA.text = isLanguageRu ? teamA.nameRu : teamA.nameEn
                    }
                }
            }
            
            if let statisticsB = (statistics.filter {$0.teamNumber?.intValue == 2}).first {
                if let teamB = statisticsB.team {
                    if UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portrait {
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.scoreByPeriods.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "periodCell", for: indexPath) as! PeriodCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        let periodCell = cell as! PeriodCell
        let count = self.collectionView.numberOfItems(inSection: 0)
        
        if indexPath.row == count - 1 {
            periodCell.periodLabel.text = NSLocalizedString("Total", comment: "")
            periodCell.teamALabel.font = UIFont.boldSystemFont(ofSize: 16)
            periodCell.teamBLabel.font = UIFont.boldSystemFont(ofSize: 16)
            
            var teamAResult: Int = 0
            var teamBResult: Int = 0
            for scoreOfPeriod in self.scoreByPeriods {
                teamAResult += scoreOfPeriod.0
                teamBResult += scoreOfPeriod.1
            }
            periodCell.teamALabel.text = "\(teamAResult)"
            periodCell.teamBLabel.text = "\(teamBResult)"
        } else {
            periodCell.teamALabel.font = UIFont.systemFont(ofSize: 16)
            periodCell.teamBLabel.font = UIFont.systemFont(ofSize: 16)
            
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
