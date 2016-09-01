//
//  PlayoffCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 26.08.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class PlayoffCell: UITableViewCell {

    @IBOutlet private var background: UIView!
    @IBOutlet private var scoresBackground: UIView!
    @IBOutlet private var avatarA: UIImageView!
    @IBOutlet private var avatarB: UIImageView!
    @IBOutlet private var teamAScoreLabel: UILabel!
    @IBOutlet private var teamBScoreLabel: UILabel!
    @IBOutlet private var teamANameLabel: UILabel!
    @IBOutlet private var teamBNameLabel: UILabel!
    
    var language: String!
    
    var playoffSerie: PlayoffSerie! {
        didSet {
            let isLanguageRu = self.language.containsString("ru")
            
            self.avatarA.image = UIImage(named: "teamStub")
            self.avatarB.image = UIImage(named: "teamStub")
            
            if let teamAId = playoffSerie.team1?.objectId {
                if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamAId)") {
                    self.avatarA.setImageWithUrl(url)
                }
            }
            self.teamANameLabel.text = isLanguageRu ? playoffSerie.team1?.nameRu : playoffSerie.team1?.nameEn
            
            if let teamBId = playoffSerie.team2?.objectId {
                if let url = NSURL(string: "http://reg.infobasket.ru/Widget/GetTeamLogo/\(teamBId)") {
                    self.avatarB.setImageWithUrl(url)
                }
            }
            self.teamBNameLabel.text = isLanguageRu ? playoffSerie.team2?.nameRu : playoffSerie.team2?.nameEn
            
            self.teamAScoreLabel.text = playoffSerie.score1?.stringValue ?? "-"
            self.teamBScoreLabel.text = playoffSerie.score2?.stringValue ?? "-"
            
            if playoffSerie.games?.count ?? 0 > 1 {
                // Добавляем счета по партиям
                let games = (playoffSerie.games as! Set<Game>).sort { ($0.date?.timeIntervalSince1970 ?? -1) < ($1.date?.timeIntervalSince1970 ?? -1) }
                var predLabel: UILabel?
                for (idx, game) in games.enumerate() {
                    let scoreLabel = UILabel()
                    scoreLabel.textAlignment = .Center
                    scoreLabel.font = UIFont.systemFontOfSize(12)
                    scoreLabel.textColor = UIColor.whiteColor()
                    scoreLabel.backgroundColor = UIColor.mlblLightOrangeColor()
                    scoreLabel.text = (game.scoreA?.stringValue ?? "-") + ":" + (game.scoreB?.stringValue ?? "-")
                    scoreLabel.layer.cornerRadius = self.scoresBackground.frame.size.height/2 - 1
                    scoreLabel.layer.masksToBounds = true
                    self.scoresBackground.addSubview(scoreLabel)
                    
                    scoreLabel.snp_makeConstraints(closure: { (make) in
                        make.top.bottom.equalTo(0)
                        make.width.equalTo(64)
                        if let _ = predLabel {
                            make.left.equalTo(predLabel!.snp_right).offset(4)
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
        self.background.layer.shadowOffset = CGSizeMake(1, 1)
        self.background.layer.shadowOpacity = 0.5
        self.background.layer.masksToBounds = false
        self.background.clipsToBounds = false
    }

    override func setSelected(selected: Bool, animated: Bool) {
        let backColor = self.background.backgroundColor
        let scoresBackColor = self.scoresBackground.backgroundColor
        
        super.setSelected(selected, animated: animated)
        
        if (selected) {
            self.background.backgroundColor = backColor
            self.scoresBackground.backgroundColor = scoresBackColor
        }
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let backColor = self.background.backgroundColor
        let scoresBackColor = self.scoresBackground.backgroundColor
        
        if (highlighted) {
            self.background.backgroundColor = backColor
            self.scoresBackground.backgroundColor = scoresBackColor
        }
    }
}