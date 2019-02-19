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
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var emptyLabel: UILabel!
    @IBOutlet fileprivate var searchBar: UISearchBar!
    
    fileprivate var numberOfLoadedPlayers = 0
    fileprivate let playersRequestBunchCount = 10
    fileprivate let rowHeight: CGFloat = 148
    fileprivate var allDataLoaded = false
    fileprivate var filteredPlayers: [Player]!
    fileprivate var searchInAction = false
    fileprivate var selectedPlayerId: Int?
    
    lazy fileprivate var fetchedResultsController: NSFetchedResultsController<Player> = {
        let fetchRequest = NSFetchRequest<Player>(entityName: Player.entityName())
        let isLanguageRu = self.dataController.language.contains("ru")
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.scrollsToTop = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tableView.scrollsToTop = false
    }
    
    // MARK: - Private
    
    fileprivate func setupTableView() {
        let spinner = UIActivityIndicatorView(style: .white)
        spinner.startAnimating()
        spinner.color = UIColor.mlblLightOrangeColor()
        spinner.frame = CGRect(x: 0, y: 0, width: 0, height: 64)
        self.tableView.tableFooterView = spinner
        self.tableView.register(UINib(nibName: "PlayerCell", bundle: nil), forCellReuseIdentifier: "playerCell")
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0)
    }
    
    fileprivate func setupSearchBar() {
        self.searchBar.barTintColor = UIColor.mlblLightOrangeColor()
        self.searchBar.tintColor = UIColor.mlblLightOrangeColor()
        self.searchBar.placeholder = NSLocalizedString("Search", comment: "")
        
        if #available(iOS 9.0, *) {
            (UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])).tintColor = UIColor.white
        } else {
            UIBarButtonItem.my_appearanceWhenContained(in: UISearchBar.self).tintColor = UIColor.white
        }
    }
    
    fileprivate func configureCell(_ cell: PlayerCell, atIndexPath indexPath: IndexPath) {
        cell.language = self.dataController.language
        cell.player = self.fetchedResultsController.object(at: indexPath)
    }
    
    fileprivate func getData(_ showIndicator: Bool) {
        // Если это - запрос первых игроков
        if self.numberOfLoadedPlayers == 0 ||
            showIndicator {
            self.activityView.startAnimating()
            self.tableView.isHidden = true
            self.emptyLabel.isHidden = true
        }
        
        self.dataController.getPlayers(self.numberOfLoadedPlayers, count: self.playersRequestBunchCount) { [weak self] (error, responseCount) in
            if let strongSelf = self {
                strongSelf.activityView.stopAnimating()
                
                if let _ = error {
                    strongSelf.emptyLabel.text = error?.localizedDescription
                    
                    if strongSelf.tableView.numberOfRows(inSection: 0) == 0 {
                        strongSelf.tableView.isHidden = true
                        strongSelf.emptyLabel.isHidden = false
                    } else {
                        strongSelf.tableView.isHidden = false
                        strongSelf.emptyLabel.isHidden = true
                        // Сообщить о потере интернета
                    }
                } else {
                    strongSelf.tableView.isHidden = false
                    strongSelf.emptyLabel.text = NSLocalizedString("No players stub", comment: "")
                    strongSelf.emptyLabel.isHidden = strongSelf.tableView.numberOfRows(inSection: 0) > 0
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
    
    fileprivate func filterContentForSearchText(_ searchText: String) {
        if searchText.count > 2 {
            func predicateForSearchText(_ text: String) -> NSPredicate {
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
                                                        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error!.userInfo[NSLocalizedDescriptionKey] as? String, preferredStyle: .alert)
                                                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                                                        
                                                        strongSelf.present(alert, animated: true, completion: nil)
                                                    }
                                                }
            })
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPlayer" {
            let playerController = segue.destination as! PlayerController
            playerController.dataController = self.dataController
            playerController.pushesController = self.pushesController
            playerController.playerId = self.selectedPlayerId!
        }
    }
}

extension PlayersController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var res = 0
        
        if let sections = self.fetchedResultsController.sections {
            let currentSection = sections[section]
            res = currentSection.numberOfObjects
        }
        
        self.emptyLabel.isHidden = res > 0 ||
            tableView.isHidden
        
        return res
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.selectedPlayerId = self.fetchedResultsController.object(at: indexPath).objectId as? Int
        
        if let _ = self.selectedPlayerId {
            self.performSegue(withIdentifier: "goToPlayer", sender: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
}

extension PlayersController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ frc: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .move:
            self.tableView.deleteRows(at: [indexPath!], with:.fade)
            self.tableView.insertRows(at: [newIndexPath!], with:.fade)
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with:.fade)
            
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with:.fade)
            
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .fade)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch(type) {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with:.fade)
            
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with:.fade)
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}

extension PlayersController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        self.searchInAction = false
        self.fetchedResultsController.fetchRequest.predicate = nil
        do {
            try self.fetchedResultsController.performFetch()
        } catch {}
        self.tableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.searchInAction = true
        self.tableView.tableFooterView = nil
        
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            searchBar.resignFirstResponder()
        } else if let searchText = searchBar.text {
            searchBar.text = (searchText as NSString).replacingCharacters(in: range, with: text)
            
            self.filterContentForSearchText(searchBar.text!)
        }
        return false
    }
}
