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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigatioBar()
        self.setupButtons()
    }
    
    // MARK: - Private
    
    @IBOutlet fileprivate var buttonsScrollView: UIScrollView!
    @IBOutlet fileprivate var sectionButtons: [UIButton]!
    @IBOutlet fileprivate var contentView: UIView!
    @IBOutlet fileprivate var selectedIndicatorView: UIView!
    fileprivate var containerController: ContainerController!
    fileprivate var choosenComp: Competition!
    
    fileprivate func setupNavigatioBar() {
        self.navigationItem.hidesBackButton = true
        
        let fetchRequest = NSFetchRequest<Competition>(entityName: Competition.entityName())
        fetchRequest.predicate = NSPredicate(format: "isChoosen = true")
        
        do {
            if let comp = try dataController.mainContext.fetch(fetchRequest).first {
                self.choosenComp = comp
                
                if self.dataController.language.contains("ru") {
                    self.title = self.choosenComp.compShortNameRu
                } else {
                    self.title = self.choosenComp.compShortNameEn
                }
            }
        } catch (let error) {
            print(error)
        }
    }
    
    fileprivate func setupButtons() {
        self.buttonsScrollView.scrollsToTop = false
        
        for (idx, button) in sectionButtons.enumerated() {
            if idx == 0 {
                self.selectedIndicatorView.snp.remakeConstraints({ (make) -> Void in
                    make.centerX.equalTo(button.snp.centerX)
                    make.width.equalTo(button.snp.width)
                })
                button.isEnabled = false
            }
            
            button.tag = idx
            
            if let controllerType = ContainerController.ControllerType(rawValue: idx) {
                switch controllerType {
                case .games:
                    button.setTitle(NSLocalizedString("Games", comment: "").uppercased(), for: UIControlState())
                case .table:
                    button.setTitle(NSLocalizedString("Table", comment: "").uppercased(), for: UIControlState())
                case .statistics:
                    button.setTitle(NSLocalizedString("Statistics", comment: "").uppercased(), for: UIControlState())
                case .players:
                    button.setTitle(NSLocalizedString("Players rating", comment: "").uppercased(), for: UIControlState())
                }
            }
        }
    }
    
    @IBAction fileprivate func sectionButtonDidTap(_ sender: UIButton) {
        for sectionButton in self.sectionButtons {
            sectionButton.isEnabled = sectionButton != sender
        }
        
        self.selectedIndicatorView.snp.remakeConstraints({ (make) -> Void in
            make.centerX.equalTo(sender.snp.centerX)
            make.width.equalTo(sender.snp.width)
        })
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
        
        if let type = ContainerController.ControllerType(rawValue: sender.tag) {
            self.containerController.goToControllerWithControllerType(type)
        }
    }
    
    @IBAction fileprivate func settingsDidTap() {
        if let settingsController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "SettingsController") as? SettingsController {
            settingsController.dataController = self.dataController
            settingsController.pushesController = self.pushesController
            self.navigationController?.pushViewController(settingsController, animated: true)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedContainer" {
            self.containerController = segue.destination as! ContainerController
            self.containerController.dataController = self.dataController
            self.containerController.pushesController = self.pushesController
        }
    }
}
