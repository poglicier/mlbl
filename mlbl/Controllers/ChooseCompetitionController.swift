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
    @IBOutlet private var goButton: UIBarButtonItem!
    private var comps = [Competition]()
    
    lazy private var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: Competition.entityName())
        fetchRequest.predicate = NSPredicate(format: "compType < 0 AND ANY children.compType < 0")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: self.dataController.language.containsString("ru") ? "compAbcNameRu" : "compAbcNameEn", ascending: true), NSSortDescriptor(key: self.dataController.language.containsString("ru") ? "compShortNameRu" : "compShortNameEn", ascending: true)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.dataController.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTableView()
        self.goButton.title = NSLocalizedString("Go", comment: "")
        
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
        self.navigationItem.rightBarButtonItem = nil
        
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
                    let fetchRequest = NSFetchRequest(entityName: Competition.entityName())
                    //        fetchRequest.predicate = NSPredicate(format: "SUBQUERY(children, x, x.@count = 2).@count = 1")
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: strongSelf.dataController.language.containsString("ru") ? "compAbcNameRu" : "compAbcNameEn", ascending: true), NSSortDescriptor(key: strongSelf.dataController.language.containsString("ru") ? "compShortNameRu" : "compShortNameEn", ascending: true)]
                    do {
                        strongSelf.comps = try strongSelf.dataController.mainContext.executeFetchRequest(fetchRequest) as! [Competition]
                    } catch{}
                    let a = strongSelf.comps.filter { $0.children?.count == 2 }
                    for aa in a {
                        print(aa.compShortNameRu)
                    }
                    
                    strongSelf.tableView.hidden = false
                    strongSelf.title = NSLocalizedString("Choose competition", comment: "")
                }
            }
        }
    }
    
    private func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let comp = fetchedResultsController.objectAtIndexPath(indexPath) as! Competition
        
        let isLanguageRu = self.dataController.language.containsString("ru")
        let abcName = isLanguageRu ? comp.compAbcNameRu : comp.compAbcNameEn
        let shortName = isLanguageRu ? comp.compShortNameRu : comp.compShortNameEn
        
        if abcName != nil {
            if shortName != nil {
                cell.textLabel?.text = "\(abcName!)-\(shortName!)"
            } else {
                cell.textLabel?.text = "\(abcName!)"
            }
        } else {
            if shortName != nil {
                cell.textLabel?.text = shortName!
            } else {
                cell.textLabel?.text = "-"
            }
        }
    }
    
    @IBAction private func goToMain() {
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
        self.navigationItem.rightBarButtonItem = self.goButton
    }
    
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Пустая реализация нужна для того, чтобы затереть реализацию BaseController,
        // в которой прячется navigationBar
    }
}