//
//  GamesController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 05.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import CoreData

class GamesController: BaseController {
    @IBOutlet private var tableView: UITableView!
    lazy private var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: Game.entityName())
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
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
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {}
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.scrollsToTop = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tableView.scrollsToTop = false
    }

    // MARK: - Private
    
    private func setupTableView() {
        self.tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
    }
    
    private func configureCell(cell: GameCell, atIndexPath indexPath: NSIndexPath) {
//        cell.game = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Game
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToGame" {
            let gameController = segue.destinationViewController as! GameController
            gameController.dataController = self.dataController
//            gameController.gameId = self.
        }
    }
}

extension GamesController: NSFetchedResultsControllerDelegate {
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

extension GamesController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let sections = self.fetchedResultsController.sections {
//            let currentSection = sections[section]
//            return currentSection.numberOfObjects
//        }
//        
//        return 0
        return 15
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 172
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let cellIdentifier = "gameCell"
        cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        self.configureCell(cell as! GameCell, atIndexPath:indexPath)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("goToGame", sender: nil)
    }
}