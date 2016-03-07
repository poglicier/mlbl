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

    @IBOutlet private var buttonsScrollView: UIScrollView!
    @IBOutlet private var sectionButtons: [UIButton]!
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var selectedIndicatorView: UIView!
    private var containerController: ContainerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupButtons()
    }
    
    // MARK: - Private
    
    private func setupButtons() {
        for (idx, button) in sectionButtons.enumerate() {
            button.tag = idx
        }
        
        if let first = self.sectionButtons.first {
            self.sectionButtonDidTap(first)
        }
    }
    
    @IBAction private func sectionButtonDidTap(sender: UIButton) {
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
        
        if let type = ContainerController.ControllerType(rawValue: sender.tag) {
            self.containerController.goToControllerWithControllerType(type)
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedContainer" {
            self.containerController = segue.destinationViewController as! ContainerController
            self.containerController.dataController = self.dataController
        }
    }
}