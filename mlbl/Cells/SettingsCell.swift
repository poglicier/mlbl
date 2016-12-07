//
//  SettingsCell.swift
//  mlbl
//
//  Created by Valentin Shamardin on 05.12.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import TTTAttributedLabel.TTTAttributedLabel

class SettingsCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Private
    
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var descriptionLabel: TTTAttributedLabel!
    
    // MARK: - Public
    
    enum CellType {
        case simple
        case red
        case disclosure
    }
    
    var cellType: CellType! {
        didSet {
            switch cellType! {
            case .simple:
                self.titleLabel.textAlignment = .left
                self.accessoryType = .none
                self.titleLabel.textColor = UIColor.mlblLightOrangeColor()
            case .red:
                self.titleLabel.textAlignment = .center
                self.accessoryType = .none
                self.titleLabel.textColor = .red
            case .disclosure:
                self.titleLabel.textAlignment = .left
                self.accessoryType = .disclosureIndicator
                self.titleLabel.textColor = UIColor.mlblLightOrangeColor()
            }
        }
    }
    
    var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    var descriptionText: NSMutableAttributedString? {
        didSet {
            if let _ = descriptionText {
                self.descriptionLabel.attributedText = descriptionText!
                self.descriptionLabel.addLink(to: URL(string: "https://github.com/poglicier/mlbl"), with: descriptionText!.mutableString.range(of: "GitHub"))
            } else {
                self.descriptionLabel.attributedText = nil
            }
        }
    }
    
    var linkDidSelectBlock: ((URL) -> ())?
}

extension SettingsCell: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if let block = self.linkDidSelectBlock {
            block(url)
        }
    }
}
