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
            let isLanguageRu = self.language.containsString("ru")
            
            self.seasonLabel.text = isLanguageRu ? seasonTeam.abcNameRu : seasonTeam.abcNameEn
            self.teamLabel.text = isLanguageRu ? seasonTeam.team?.shortNameRu : seasonTeam.team?.shortNameEn
        }
    }
    
    // MARK: - Private
    
    @IBOutlet private var background: UIView!
    @IBOutlet private var seasonLabel: UILabel!
    @IBOutlet private var teamLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let isLanguageRu = self.language.containsString("ru")
        if UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) {
            self.seasonLabel.text = isLanguageRu ? seasonTeam.abcNameRu : seasonTeam.abcNameEn
            self.teamLabel.text = isLanguageRu ? seasonTeam.team?.shortNameRu : seasonTeam.team?.shortNameEn
        } else {
            self.seasonLabel.text = isLanguageRu ? seasonTeam.nameRu : seasonTeam.nameEn
            self.teamLabel.text = isLanguageRu ? seasonTeam.team?.nameRu : seasonTeam.team?.nameEn
        }
    }
}