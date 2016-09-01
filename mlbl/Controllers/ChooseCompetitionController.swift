//
//  ChooseCompetitionController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 12.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import CoreData

class ChooseCompetitionController: BaseController {
    @IBOutlet private var tableView: UITableView!
    
    lazy private var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: Competition.entityName())
        fetchRequest.predicate = NSPredicate(format: "compType < 0 AND ANY children.compType >= 0")
        let isLanguageRu = self.dataController.language.containsString("ru")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: isLanguageRu ? "parent.compShortNameRu" : "parent.compShortNameEn", ascending: true),
                                        NSSortDescriptor(key: isLanguageRu ? "compAbcNameRu" : "compAbcNameEn", ascending: true), NSSortDescriptor(key: self.dataController.language.containsString("ru") ? "compShortNameRu" : "compShortNameEn", ascending: true)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.dataController.mainContext,
            sectionNameKeyPath: isLanguageRu ? "parent.compShortNameRu" : "parent.compShortNameEn",
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTableView()
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {}
        
        self.getData()
    }
    
    // MARK: - Private
    
    private func setupTableView() {
        self.tableView.layer.cornerRadius = 10
        self.tableView.layer.masksToBounds = true
    }
    
    private func getData() {
        self.activityView.startAnimating()
        self.tableView.hidden = true
        
        self.dataController.getCompetitions() { [weak self] (error) in
            if let strongSelf = self {
                strongSelf.activityView.stopAnimating()
                if let _ = error {
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: "Failed to connect", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { (_) -> Void in
                        strongSelf.getData()
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                    
                    strongSelf.presentViewController(alert, animated: true, completion: nil)
                } else {
                    strongSelf.tableView.hidden = false
                    strongSelf.title = NSLocalizedString("Choose competition", comment: "")
                }
            }
        }
    }
    
    private func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let comp = fetchedResultsController.objectAtIndexPath(indexPath) as! Competition
        
        let isLanguageRu = self.dataController.language.containsString("ru")
        let shortName = isLanguageRu ? comp.compShortNameRu : comp.compShortNameEn
        
        if let _ = shortName {
            cell.textLabel?.text = shortName!
        } else {
            cell.textLabel?.text = "-"
        }
    }
    
    private func goToMain() {
        if let selectedPath = self.tableView.indexPathForSelectedRow {
            let fetchRequest = NSFetchRequest(entityName: Competition.entityName())
            fetchRequest.predicate = NSPredicate(format: "isChoosen = true")
            
            do {
                let oldComp = try self.dataController.mainContext.executeFetchRequest(fetchRequest).first as? Competition
                let newComp = self.fetchedResultsController.objectAtIndexPath(selectedPath) as! Competition
                if oldComp != newComp {
                    oldComp?.isChoosen = false
                    newComp.isChoosen = true

                    // Удаляем игроков старого чемпионата
                    let playersRequest = NSFetchRequest(entityName: Player.entityName())
                    do {
                        if let players = try self.dataController.mainContext.executeFetchRequest(playersRequest) as? [Player] {
                            for player in players {
                                self.dataController.mainContext.deleteObject(player)
                                print("DELETE Player \(player.lastNameRu)")
                            }
                        }
                    }
                    
                    // Удаляем игры старого чемпионата
                    let gamesRequest = NSFetchRequest(entityName: Game.entityName())
                    do {
                        if let games = try self.dataController.mainContext.executeFetchRequest(gamesRequest) as? [Game] {
                            for game in games {
                                self.dataController.mainContext.deleteObject(game)
                                print("DELETE Game \(game.date)")
                            }
                        }
                    }
                }
            } catch {}
            
            self.dataController.saveContext(self.dataController.mainContext)
            self.performSegueWithIdentifier("goToMain", sender: nil)
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToMain" {
            (segue.destinationViewController as? BaseController)?.dataController = self.dataController
        }
    }
    
    @IBAction private func prepareForUnwind(segue: UIStoryboardSegue) {
    }
}

extension ChooseCompetitionController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(frc: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch(type) {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation:.Fade)
            
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation:.Fade)
            
        case .Update:
            self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation:.Fade)
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation:.Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch(type) {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation:.Fade)
            
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation:.Fade)
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}

extension ChooseCompetitionController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = self.fetchedResultsController.sections?[section]
        if let competition = sectionInfo?.objects?.first as? Competition {
            let isLanguageRu = self.dataController.language.containsString("ru")
            return isLanguageRu ? competition.parent?.compShortNameRu : competition.parent?.compShortNameEn
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = self.fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }

        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.mlblLightOrangeColor()
        let label = UILabel()
        if #available(iOS 8.2, *) {
            label.font = UIFont.systemFontOfSize(17, weight: UIFontWeightMedium)
        } else {
            label.font = UIFont.systemFontOfSize(17)
        }
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.textColor = UIColor.whiteColor()
        view.addSubview(label)
        label.snp_makeConstraints { (make) in
            make.left.equalTo(16)
            make.top.right.bottom.equalTo(0)
        }
        
        return view
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let cellIdentifier = "chooseCompCell"
        cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        cell.textLabel?.textColor = UIColor.mlblDarkOrangeColor()
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        self.configureCell(cell, atIndexPath:indexPath)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.goToMain()
    }
    
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Пустая реализация нужна для того, чтобы затереть реализацию BaseController,
        // в которой прячется navigationBar
    }
}