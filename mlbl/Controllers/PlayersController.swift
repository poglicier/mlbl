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
    @IBOutlet private var searchBar: UISearchBar!
    
    private var numberOfLoadedPlayers = 0
    private let playersRequestBunchCount = 10
    private let rowHeight: CGFloat = 148
    private var allDataLoaded = false
    private var filteredPlayers: [Player]!
    private var searchInAction = false
    private var selectedPlayerId: Int?
    
    lazy private var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: Player.entityName())
        let isLanguageRu = self.dataController.language.containsString("ru")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: isLanguageRu ? "lastNameRu" : "lastNameEn", ascending: true), NSSortDescriptor(key: isLanguageRu ? "firstNameRu" : "firstNameEn", ascending: true), NSSortDescriptor(key: isLanguageRu ? "lastNameEn" : "lastNameRu", ascending: true), NSSortDescriptor(key: isLanguageRu ? "firstNameEn" : "firstNameRu", ascending: true)]
        
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
        self.setupSearchBar()
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {}
        
        self.getData(true)
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
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .White)
        spinner.startAnimating()
        spinner.color = UIColor.mlblLightOrangeColor()
        spinner.frame = CGRectMake(0, 0, 0, 64)
        self.tableView.tableFooterView = spinner
        self.tableView.registerNib(UINib(nibName: "PlayerCell", bundle: nil), forCellReuseIdentifier: "playerCell")
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0)
    }
    
    private func setupSearchBar() {
        self.searchBar.barTintColor = UIColor.mlblLightOrangeColor()
        self.searchBar.tintColor = UIColor.mlblLightOrangeColor()
        self.searchBar.placeholder = NSLocalizedString("Search", comment: "")
        
        if #available(iOS 9.0, *) {
            (UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self])).tintColor = UIColor.whiteColor()
        } else {
            UIBarButtonItem.my_appearanceWhenContainedIn(UISearchBar.self).tintColor = UIColor.whiteColor()
        }
    }
    
    private func configureCell(cell: PlayerCell, atIndexPath indexPath: NSIndexPath) {
        cell.language = self.dataController.language
        cell.player = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Player
    }
    
    private func getData(showIndicator: Bool) {
        // Если это - запрос первых игроков
        if self.numberOfLoadedPlayers == 0 ||
            showIndicator {
            self.activityView.startAnimating()
            self.tableView.hidden = true
            self.emptyLabel.hidden = true
        }
        
        self.dataController.getPlayers(self.numberOfLoadedPlayers, count: self.playersRequestBunchCount) { [weak self] (error, responseCount) in
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
                    strongSelf.allDataLoaded = responseCount < strongSelf.playersRequestBunchCount
                    
                    if strongSelf.allDataLoaded {
                        strongSelf.tableView.tableFooterView = nil
                    } else {
                        strongSelf.setupTableView()
                    }
                    
                    strongSelf.numberOfLoadedPlayers += responseCount
                }
            }
        }
    }
    
    override func willEnterForegroud() {
        self.getData(false)
    }
    
    private func filterContentForSearchText(searchText: String) {
        if searchText.characters.count > 2 {
            func predicateForSearchText(text: String) -> NSPredicate {
                let p1 = NSPredicate(format: "lastNameRu CONTAINS[cd] %@", text)
                let p2 = NSPredicate(format: "lastNameEn CONTAINS[cd] %@", text)
                let p3 = NSPredicate(format: "firstNameRu CONTAINS[cd] %@", text)
                let p4 = NSPredicate(format: "firstNameEn CONTAINS[cd] %@", text)
                return NSCompoundPredicate(orPredicateWithSubpredicates: [p1, p2, p3, p4])
            }
            
            self.fetchedResultsController.fetchRequest.predicate = predicateForSearchText(searchText)
            do {
                try self.fetchedResultsController.performFetch()
            } catch {}
            self.tableView.reloadData()
            
            self.dataController.searchPlayers(0,
                                              count: 15,
                                              searchText: searchText,
                                              completion: { [weak self] (error, emptyAnswer) in
                                                if let strongSelf = self {
                                                    if let _ = error {
                                                        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error!.userInfo[NSLocalizedDescriptionKey] as? String, preferredStyle: .Alert)
                                                        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
                                                        
                                                        strongSelf.presentViewController(alert, animated: true, completion: nil)
                                                    }
                                                }
            })
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToPlayer" {
            let playerController = segue.destinationViewController as! PlayerController
            playerController.dataController = self.dataController
            playerController.playerId = self.selectedPlayerId!
        }
    }
}

extension PlayersController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var res = 0
        
        if let sections = self.fetchedResultsController.sections {
            let currentSection = sections[section]
            res = currentSection.numberOfObjects
        }
        
        self.emptyLabel.hidden = res > 0 ||
            tableView.hidden
        
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
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        
        self.configureCell(cell as! PlayerCell, atIndexPath:indexPath)
        
        if self.searchInAction &&
            self.searchBar.text != "" {
        } else {
            if !self.allDataLoaded &&
                indexPath.row >= self.numberOfLoadedPlayers - 1 {
                self.getData(false)
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.selectedPlayerId = (self.fetchedResultsController.objectAtIndexPath(indexPath) as! Player).objectId as? Int
        
        if let _ = self.selectedPlayerId {
            self.performSegueWithIdentifier("goToPlayer", sender: nil)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
}

extension PlayersController: NSFetchedResultsControllerDelegate {
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

extension PlayersController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        self.searchInAction = false
        self.fetchedResultsController.fetchRequest.predicate = nil
        do {
            try self.fetchedResultsController.performFetch()
        } catch {}
        self.tableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        self.searchInAction = true
        self.tableView.tableFooterView = nil
        
        return true
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            searchBar.resignFirstResponder()
        } else if let searchText = searchBar.text {
            searchBar.text = (searchText as NSString).stringByReplacingCharactersInRange(range, withString: text)
            
            self.filterContentForSearchText(searchBar.text!)
        }
        return false
    }
}