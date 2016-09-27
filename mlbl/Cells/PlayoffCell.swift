//
//  PlayoffCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 26.08.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class PlayoffCell: UITableViewCell {

    @IBOutlet fileprivate var background: UIView!
    @IBOutlet fileprivate var scoresBackground: UIView!
    @IBOutlet fileprivate var avatarA: UIImageView!
    @IBOutlet fileprivate var avatarB: UIImageView!
    @IBOutlet fileprivate var teamAScoreLabel: UILabel!
    @IBOutlet fileprivate var teamBScoreLabel: UILabel!
    @IBOutlet fileprivate var teamANameLabel: UILabel!
    @IBOutlet fileprivate var teamBNameLabel: UILabel!
    
    var language: String!
    
    var playoffSerie: PlayoffSerie! {
        didSet {
            let isLanguageRu = self.language.contains("ru")
            
            self.avatarA.image = UIImage(named: "teamStub")
            self.avatarB.image = UIImage(named: "teamStub")
            
            if let teamAId = playoffSerie.team1?.objectId {
                if let url = URL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamAId)") {
                    self.avatarA.setImageWithUrl(url)
                }
            }
            self.teamANameLabel.text = isLanguageRu ? playoffSerie.team1?.nameRu : playoffSerie.team1?.nameEn
            
            if let teamBId = playoffSerie.team2?.objectId {
                if let url = URL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamBId)") {
                    self.avatarB.setImageWithUrl(url)
                }
            }
            self.teamBNameLabel.text = isLanguageRu ? playoffSerie.team2?.nameRu : playoffSerie.team2?.nameEn
            
            self.teamAScoreLabel.text = playoffSerie.score1?.stringValue ?? "-"
            self.teamBScoreLabel.text = playoffSerie.score2?.stringValue ?? "-"
            
            if playoffSerie.games?.count ?? 0 > 1 {
                // Добавляем счета по партиям
                let games = (playoffSerie.games as! Set<Game>).sorted { ($0.date?.timeIntervalSince1970 ?? -1) < ($1.date?.timeIntervalSince1970 ?? -1) }
                var predLabel: UILabel?
                for (idx, game) in games.enumerated() {
                    let scoreLabel = UILabel()
                    scoreLabel.textAlignment = .center
                    scoreLabel.font = UIFont.systemFont(ofSize: 12)
                    scoreLabel.textColor = UIColor.white
                    scoreLabel.backgroundColor = UIColor.mlblLightOrangeColor()
                    scoreLabel.text = (game.scoreA?.stringValue ?? "-") + ":" + (game.scoreB?.stringValue ?? "-")
                    scoreLabel.layer.cornerRadius = self.scoresBackground.frame.size.height/2 - 1
                    scoreLabel.layer.masksToBounds = true
                    self.scoresBackground.addSubview(scoreLabel)
                    
                    scoreLabel.snp.makeConstraints({ (make) in
                        make.top.bottom.equalTo(0)
                        make.width.equalTo(64)
                        if let _ = predLabel {
                            make.left.equalTo(predLabel!.snp.right).offset(4)
                        } else {
                            make.left.equalTo(0)
                        }
                        
                        if idx == games.count-1 {
                            make.right.equalTo(0)
                        }
                    })
                    
                    predLabel = scoreLabel
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for view in self.background.subviews {
            if let label = view as? UILabel {
                label.highlightedTextColor = UIColor.mlblLightOrangeColor()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.scoresBackground.subviews.forEach({ $0.removeFromSuperview() })
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        let backColor = self.background.backgroundColor
        let scoresBackColor = self.scoresBackground.backgroundColor
        
        super.setSelected(selected, animated: animated)
        
        if (selected) {
            self.background.backgroundColor = backColor
            self.scoresBackground.backgroundColor = scoresBackColor
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let backColor = self.background.backgroundColor
        let scoresBackColor = self.scoresBackground.backgroundColor
        
        if (highlighted) {
            self.background.backgroundColor = backColor
            self.scoresBackground.backgroundColor = scoresBackColor
        }
    }
}
