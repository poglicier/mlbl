//
//  ChooseRegionController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 12.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import CoreData

class ChooseRegionController: BaseController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var activityView: UIActivityIndicatorView!
    @IBOutlet private var goButton: UIBarButtonItem!
    
    lazy private var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: Region.entityName())
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "objectId", ascending: true)]
        
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
        
        self.goButton.title = NSLocalizedString("Go", comment: "")
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {}
        
        self.getData()
    }
    
    // MARK: - Private
    
    private func getData() {
        self.activityView.hidden = false
        self.activityView.startAnimating()
        self.tableView.hidden = true
        self.navigationItem.rightBarButtonItem = nil
        
        self.dataController.getRegions({ [weak self] in
            if let strongSelf = self {
                strongSelf.activityView.hidden = true
                strongSelf.activityView.stopAnimating()
                strongSelf.tableView.hidden = false
                strongSelf.title = NSLocalizedString("Choose region", comment: "")
            }
            }) { [weak self] (let error) -> Void in
                if let strongSelf = self {
                    strongSelf.activityView.hidden = true
                    strongSelf.activityView.stopAnimating()
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: "Failed to connect", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { (_) -> Void in
                        strongSelf.getData()
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                    
                    self?.presentViewController(alert, animated: true, completion: nil)
                }
        }
    }
    
    private func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let region = fetchedResultsController.objectAtIndexPath(indexPath) as! Region
        
        if self.dataController.language.containsString("ru") {
            cell.textLabel?.text = region.nameRu
        } else {
            cell.textLabel?.text = region.nameEn
        }
    }
    
    @IBAction private func goToMain() {
        if let selectedPath = self.tableView.indexPathForSelectedRow {
            let fetchRequest = NSFetchRequest(entityName: Region.entityName())
            fetchRequest.predicate = NSPredicate(format: "isChoosen = true")
            
            do {
                if let region = try self.dataController.mainContext.executeFetchRequest(fetchRequest).first as? Region {
                    region.isChoosen = false
                }
            } catch {}
            
            let region = self.fetchedResultsController.objectAtIndexPath(selectedPath) as! Region
            region.isChoosen = true
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

extension ChooseRegionController: NSFetchedResultsControllerDelegate {
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

extension ChooseRegionController: UITableViewDataSource, UITableViewDelegate {
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
        let cellIdentifier = "chooseRegionCell"
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
}