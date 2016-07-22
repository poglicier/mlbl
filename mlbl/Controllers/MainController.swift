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
    private var choosenComp: Competition!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigatioBar()
        self.setupButtons()
    }
    
    // MARK: - Private
    
    private func setupNavigatioBar() {
        self.navigationItem.hidesBackButton = true
        
        let fetchRequest = NSFetchRequest(entityName: Competition.entityName())
        fetchRequest.predicate = NSPredicate(format: "isChoosen = true")
        
        do {
            if let comp = try dataController.mainContext.executeFetchRequest(fetchRequest).first as? Competition {
                self.choosenComp = comp
                
                if self.dataController.language.containsString("ru") {
                    self.title = self.choosenComp.compAbcNameRu
                } else {
                    self.title = self.choosenComp.compAbcNameEn
                }
            }
        } catch {}
    }
    
    private func setupButtons() {
        self.buttonsScrollView.scrollsToTop = false
        
        for (idx, button) in sectionButtons.enumerate() {
            if idx == 0 {
                self.selectedIndicatorView.snp_remakeConstraints(closure: { (make) -> Void in
                    make.centerX.equalTo(button.snp_centerX)
                    make.width.equalTo(button.snp_width)
                })
            }
            
            button.tag = idx
            
            if let controllerType = ContainerController.ControllerType(rawValue: idx) {
                switch controllerType {
                case .Games:
                    button.setTitle(NSLocalizedString("Games", comment: "").uppercaseString, forState: .Normal)
                case .Table:
                    button.setTitle(NSLocalizedString("Table", comment: "").uppercaseString, forState: .Normal)
                case .Statistics:
                    button.setTitle(NSLocalizedString("Statistics", comment: "").uppercaseString, forState: .Normal)
                case .Players:
                    button.setTitle(NSLocalizedString("Players rating", comment: "").uppercaseString, forState: .Normal)
                }
            }
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
        if let ChooseCompetitionController = self.storyboard?.instantiateViewControllerWithIdentifier("ChooseCompetitionController") as? BaseController {
            ChooseCompetitionController.dataController = self.dataController
            self.navigationController?.setViewControllers([ChooseCompetitionController], animated: true)
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