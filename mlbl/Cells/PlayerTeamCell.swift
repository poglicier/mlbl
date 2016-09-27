//
//  PlayerTeamCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 05.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class PlayerTeamCell: UITableViewCell {

    // MARK: - Public
    
    var language: String!
    var color: UIColor? {
        didSet {
            self.background.backgroundColor = color
        }
    }
    
    var seasonTeam: SeasonTeam! {
        didSet {
            let isLanguageRu = self.language.contains("ru")
            
            self.seasonLabel.text = isLanguageRu ? seasonTeam.abcNameRu : seasonTeam.abcNameEn
            self.teamLabel.text = isLanguageRu ? seasonTeam.team?.shortNameRu : seasonTeam.team?.shortNameEn
        }
    }
    
    // MARK: - Private
    
    @IBOutlet fileprivate var background: UIView!
    @IBOutlet fileprivate var seasonLabel: UILabel!
    @IBOutlet fileprivate var teamLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let isLanguageRu = self.language.contains("ru")
        if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
            self.seasonLabel.text = isLanguageRu ? seasonTeam.abcNameRu : seasonTeam.abcNameEn
            self.teamLabel.text = isLanguageRu ? seasonTeam.team?.shortNameRu : seasonTeam.team?.shortNameEn
        } else {
            self.seasonLabel.text = isLanguageRu ? seasonTeam.nameRu : seasonTeam.nameEn
            self.teamLabel.text = isLanguageRu ? seasonTeam.team?.nameRu : seasonTeam.team?.nameEn
        }
    }
}
