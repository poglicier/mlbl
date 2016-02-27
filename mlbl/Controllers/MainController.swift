//
//  MainController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 27.02.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import SnapKit

class MainController: BaseController {
    private enum Buttons {
        case Games
        case Teams
        case Players
        case Schedule
        case Ratings
    }
    
    @IBOutlet private var buttonsScrollView: UIScrollView!
    @IBOutlet private var sectionButtons: [UIButton]!
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var selectedIndicatorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let first = self.sectionButtons.first {
            self.sectionButtonDidTap(first)
        }
    }
    
    @IBAction func sectionButtonDidTap(sender: UIButton) {
        for sectionButton in self.sectionButtons {
            sectionButton.selected = sectionButton == sender
        }
        
        self.selectedIndicatorView.snp_remakeConstraints(closure: { (make) -> Void in
            make.centerX.equalTo(sender.snp_centerX)
            make.width.equalTo(sender.snp_width)
        })
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
}