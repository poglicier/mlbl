//
//  PlayersController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 28.02.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import CoreData

class PlayersController: BaseController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var emptyLabel: UILabel!
    
    private let bunchSize = 10
    private let rowHeight: CGFloat = 145
    private var allDataLoaded = false
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredPlayers: [Player]!
    
    lazy private var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: Player.entityName())
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: self.dataController.language.containsString("ru") ? "lastNameRu" : "lastNameEn", ascending: true), NSSortDescriptor(key: self.dataController.language.containsString("ru") ? "firstNameRu" : "firstNameEn", ascending: true)]
        
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
        
        self.getData(0)
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
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
        spinner.startAnimating()
        spinner.color = UIColor.mlblLightOrangeColor()
        spinner.frame = CGRectMake(0, 0, 0, 64)
        self.tableView.tableFooterView = spinner
        
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
//        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchBar.barTintColor = UIColor.mlblLightOrangeColor()
        self.searchController.searchBar.tintColor = UIColor.whiteColor()
        self.searchController.searchBar.delegate = self
    }
    
    private func configureCell(cell: PlayerCell, atIndexPath indexPath: NSIndexPath) {
        cell.language = self.dataController.language
        
        if self.searchController.active &&
            self.searchController.searchBar.text != "" {
            cell.player = self.filteredPlayers[indexPath.row]
        } else {
            cell.player = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Player
        }
    }
    
    private func getData(from: Int) {
        if from == 0 {
            self.activityView.startAnimating()
            self.tableView.hidden = true
            self.emptyLabel.hidden = true
        }
        
        self.dataController.getPlayers(from, count: self.bunchSize) { [weak self] (error, emptyAnswer) in
            if let strongSelf = self {
                strongSelf.activityView.stopAnimating()
                
                if let _ = error {
                    strongSelf.emptyLabel.text = error?.localizedDescription
                    
                    if strongSelf.tableView.numberOfRowsInSection(0) == 0 {
                        strongSelf.tableView.hidden = true
                        strongSelf.emptyLabel.hidden = false
                    } else {
                        strongSelf.tableView.hidden = false
                        strongSelf.emptyLabel.hidden = true
                        // Сообщить о потере интернета
                    }
                } else {
                    strongSelf.tableView.hidden = false
                    strongSelf.emptyLabel.text = NSLocalizedString("No players stub", comment: "")
                    strongSelf.emptyLabel.hidden = strongSelf.tableView.numberOfRowsInSection(0) > 0
                    strongSelf.allDataLoaded = emptyAnswer
                    
                    if emptyAnswer {
                        strongSelf.tableView.tableFooterView = nil
                    } else {
                        strongSelf.setupTableView()
                    }
                }
            }
        }
    }
    
    private func filterContentForSearchText(searchText: String) {
        if searchText.characters.count > 2 {
            self.dataController.searchPlayers(0,
                                              count: 15,
                                              searchText: searchText,
                                              completion: { [weak self] (error, emptyAnswer) in
                                                if let strongSelf = self {
                                                    if let players = strongSelf.fetchedResultsController.fetchedObjects as? [Player] {
                                                        strongSelf.filteredPlayers = players.filter { player in
                                                            let lastNameRu = player.lastNameRu?.lowercaseString.containsString(searchText.lowercaseString) ?? false
                                                            let lastNameEn = player.lastNameEn?.lowercaseString.containsString(searchText.lowercaseString) ?? false
                                                            let firstNameRu = player.firstNameRu?.lowercaseString.containsString(searchText.lowercaseString) ?? false
                                                            let firstNameEn = player.firstNameEn?.lowercaseString.containsString(searchText.lowercaseString) ?? false
                                                            return lastNameRu || lastNameEn || firstNameRu || firstNameEn
                                                        }
                                                        
                                                        strongSelf.tableView.reloadData()
                                                    }
                                                }
            })
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PlayersController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var res = 0
        
        if self.searchController.active &&
            self.searchController.searchBar.text != "" {
            res = self.filteredPlayers.count
        } else {
            if let sections = self.fetchedResultsController.sections {
                let currentSection = sections[section]
                res = currentSection.numberOfObjects
            }
            
            self.emptyLabel.hidden = res > 0 ||
                tableView.hidden
        }
        
        return res
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("playerCell", forIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        self.configureCell(cell as! PlayerCell, atIndexPath:indexPath)
        
        if self.searchController.active &&
            self.searchController.searchBar.text != "" {
            self.tableView.tableFooterView = nil
        } else {
            if !self.allDataLoaded &&
                indexPath.row >= tableView.numberOfRowsInSection(0) - 1 {
                self.getData(self.fetchedResultsController.fetchedObjects?.count ?? 0)
            }
        }
    }
}

extension PlayersController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(frc: NSFetchedResultsController) {
        if self.searchController.active &&
            self.searchController.searchBar.text != "" {
            return
        }
        
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if self.searchController.active &&
            self.searchController.searchBar.text != "" {
            return
        }
        
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
        if self.searchController.active &&
            self.searchController.searchBar.text != "" {
            return
        }
        
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
        if self.searchController.active &&
            self.searchController.searchBar.text != "" {
            return
        }
        
        self.tableView.endUpdates()
    }
}

extension PlayersController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension PlayersController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchController.resignFirstResponder()
    }
}