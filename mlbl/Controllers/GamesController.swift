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
    @IBOutlet private var dateLabel: UILabel!
    @IBOutlet private var emptyLabel: UILabel!
    @IBOutlet private var datesView: UIView!
    @IBOutlet private var prevButton: UIButton!
    @IBOutlet private var nextButton: UIButton!
    @IBOutlet private var tableViewCenterX: NSLayoutConstraint!
    
    private var selectedGameId: Int?
    private var prevDate: NSDate?
    private var currentDate: NSDate? {
        didSet {
            if let _ = currentDate {
                self.dateLabel.text = self.dateFormatter.stringFromDate(currentDate!)
            } else {
                self.dateLabel.text = nil
            }
        }
    }
    private var nextDate: NSDate?
    
    lazy private var dateFormatter: NSDateFormatter = {
        let res = NSDateFormatter()
        res.dateFormat = "dd.MM.yyyy"
        res.dateStyle = .ShortStyle
        return res
    }()
    
    lazy private var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: Game.entityName())
        let dates = self.datesIntervalForDate(NSDate())
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
        self.setupDate()
        self.setupButtons()
        self.setupEmptyLabel()
        self.getData()
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
    
    private func setupDate() {
        self.currentDate = NSDate()
    }
    
    private func setupButtons() {
        self.prevButton.enabled = false
        self.nextButton.enabled = false
    }
    
    private func setupEmptyLabel() {
        self.emptyLabel.text = NSLocalizedString("No games stub", comment: "")
        self.emptyLabel.hidden = true
    }
    
    private func getData() {
        if let date = self.currentDate {
            self.activityView.startAnimating()
            self.tableView.hidden = true

            let dates = self.datesIntervalForDate(date)
            self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "date > %@ AND date < %@", dates.0, dates.1)
            
            do {
                try self.fetchedResultsController.performFetch()
            } catch {}
            self.tableView.reloadData()
            
            self.dataController.getGamesForDate(date) { [weak self] (error, newPrevDate, newNextDate) in
                if let strongSelf = self {
                    strongSelf.activityView.stopAnimating()

                    if let _ = error {
                        strongSelf.prevButton.enabled = strongSelf.prevDate != nil
                        strongSelf.nextButton.enabled = strongSelf.nextDate != nil
                    } else {
                        strongSelf.tableView.hidden = false
                        strongSelf.prevButton.enabled = newPrevDate != nil
                        strongSelf.nextButton.enabled = newNextDate != nil
                        
                        strongSelf.prevDate = newPrevDate
                        strongSelf.nextDate = newNextDate
                    }
                }
            }
        }
    }
    
    private func setupTableView() {
        self.tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
    }
    
    private func configureCell(cell: GameCell, atIndexPath indexPath: NSIndexPath) {
        cell.language = self.dataController.language
        cell.game = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Game
    }
    
    @IBAction private func goToPrevDate() {
        self.currentDate = self.prevDate
        
        self.prevButton.enabled = false
        self.nextButton.enabled = false
        
        self.tableViewCenterX.constant = self.tableView.frame.size.width
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
            }) { (Bool) in
                self.tableViewCenterX.constant = 0
                self.view.layoutIfNeeded()
                
                self.getData()
            }
    }
    
    @IBAction private func goToNextDate() {
        self.currentDate = self.nextDate
        
        self.prevButton.enabled = false
        self.nextButton.enabled = false
        
        self.tableViewCenterX.constant = -self.tableView.frame.size.width
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
        }) { (Bool) in
            self.tableViewCenterX.constant = 0
            self.view.layoutIfNeeded()
            
            self.getData()
        }
    }
    
    private func datesIntervalForDate(date: NSDate) -> (start: NSDate, end: NSDate) {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Day], fromDate:date)
        let startDate = calendar.dateFromComponents(components)
        components.day += 1
        let endDate = calendar.dateFromComponents(components)
        
        return (startDate!, endDate!)
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToGame" {
            let gameController = segue.destinationViewController as! GameController
            gameController.dataController = self.dataController
            gameController.gameId = self.selectedGameId!
        }
    }
}

extension GamesController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(frc: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation:.Fade)
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation:.Fade)
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation:.Fade)
            
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation:.Fade)
            
        case .Update:
            self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
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
        var res = 0
        if let sections = self.fetchedResultsController.sections {
            let currentSection = sections[section]
            res = currentSection.numberOfObjects
        }
        
        self.emptyLabel.hidden = res > 0
        
        return res
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.selectedGameId = (self.fetchedResultsController.objectAtIndexPath(indexPath) as! Game).objectId as? Int
        if let _ = self.selectedGameId {
            self.performSegueWithIdentifier("goToGame", sender: nil)
        }
    }
}