//
//  MainController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 27.02.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import SnapKit
import CoreData

class MainController: BaseController {

    @IBOutlet private var buttonsScrollView: UIScrollView!
    @IBOutlet private var sectionButtons: [UIButton]!
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var selectedIndicatorView: UIView!
    private var containerController: ContainerController!
    private var choosenRegion: Region!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigatioBar()
        self.setupButtons()
    }
    
    // MARK: - Private
    
    private func setupNavigatioBar() {
        self.navigationItem.hidesBackButton = true
        
        let fetchRequest = NSFetchRequest(entityName: Region.entityName())
        fetchRequest.predicate = NSPredicate(format: "isChoosen = true")
        
        do {
            if let region = try dataController.mainContext.executeFetchRequest(fetchRequest).first as? Region {
                self.choosenRegion = region
                
                if self.dataController.language.containsString("ru") {
                    self.title = self.choosenRegion.nameRu
                } else {
                    self.title = self.choosenRegion.nameEn
                }
            }
        } catch {}
    }
    
    private func setupButtons() {
        for (idx, button) in sectionButtons.enumerate() {
            button.tag = idx
            
            if let controllerType = ContainerController.ControllerType(rawValue: idx) {
                switch controllerType {
                case .Games:
                    button.setTitle(NSLocalizedString("Games", comment: "").uppercaseString, forState: .Normal)
                case .Teams:
                    button.setTitle(NSLocalizedString("Teams", comment: "").uppercaseString, forState: .Normal)
                case .Players:
                    button.setTitle(NSLocalizedString("Players", comment: "").uppercaseString, forState: .Normal)
                case .Schedule:
                    button.setTitle(NSLocalizedString("Schedule", comment: "").uppercaseString, forState: .Normal)
                case .Ratings:
                    button.setTitle(NSLocalizedString("Players rating", comment: "").uppercaseString, forState: .Normal)
                }
            }
        }
        
        if let first = self.sectionButtons.first {
            self.sectionButtonDidTap(first)
        }
    }
    
    @IBAction private func sectionButtonDidTap(sender: UIButton) {
        for sectionButton in self.sectionButtons {
            sectionButton.enabled = sectionButton != sender
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
    
    @IBAction private func goToChooseRegion() {
        if let chooseRegionController = self.storyboard?.instantiateViewControllerWithIdentifier("ChooseRegionController") as? BaseController {
            chooseRegionController.dataController = self.dataController
            self.navigationController?.setViewControllers([chooseRegionController], animated: true)
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