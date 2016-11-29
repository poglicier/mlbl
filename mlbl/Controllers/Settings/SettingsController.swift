//
//  SettingsController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 28.11.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import CoreData

class SettingsController: BaseController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViews()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Private
    
    @IBOutlet fileprivate var changeChampionshipButton: UIButton!

    fileprivate func setupViews() {
        self.title = NSLocalizedString("Settings", comment: "")
        
        self.changeChampionshipButton.setTitle(NSLocalizedString("Сменить чемпионат", comment: ""), for: .normal)
    }
    
    @IBAction fileprivate func changeChampionshipDidTap() {
        if let chooseCompetitionController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "ChooseCompetitionController") as? BaseController {
            let fetchRequest = NSFetchRequest<Competition>(entityName: Competition.entityName())
            fetchRequest.predicate = NSPredicate(format: "isChoosen = true")
            do {
                let comp = try self.dataController.mainContext.fetch(fetchRequest).first
                comp?.isChoosen = false
                self.dataController.saveContext(self.dataController.mainContext)
            } catch {}
            
            chooseCompetitionController.dataController = self.dataController
            self.navigationController?.setViewControllers([chooseCompetitionController], animated: false)
        }
    }
}
