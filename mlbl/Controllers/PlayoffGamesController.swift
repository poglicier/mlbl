//
//  PlayoffGamesController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 30.08.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import CoreData

class PlayoffGamesController: BaseController {

    @IBOutlet fileprivate var emptyLabel: UILabel!
    @IBOutlet fileprivate var tableView: UITableView!
    fileprivate var selectedGameId: Int?

    var gamesIds: [Int]!
    
    lazy fileprivate var fetchedResultsController: NSFetchedResultsController<Game> = {
        let fetchRequest = NSFetchRequest<Game>(entityName: Game.entityName())
        fetchRequest.predicate = NSPredicate(format: "objectId IN %@", self.gamesIds)
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
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.setupTableView()
        self.setupEmptyLabel()
    
        do {
            try self.fetchedResultsController.performFetch()
        } catch {}
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGame" {
            let gameController = segue.destination as! GameController
            gameController.dataController = self.dataController
            gameController.pushesController = self.pushesController
            gameController.gameId = self.selectedGameId!
        }
    }
    
    // MARK: - Private
    
    fileprivate func setupEmptyLabel() {
        self.emptyLabel.text = NSLocalizedString("No games stub", comment: "")
        self.emptyLabel.isHidden = true
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Пустая реализация нужна для того, чтобы затереть реализацию BaseController,
        // в которой прячется navigationBar
    }
    
    fileprivate func setupTableView() {
        self.tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        self.tableView.register(UINib(nibName: "GameCell", bundle: nil), forCellReuseIdentifier: "gameCell");
    }
    
    fileprivate func configureCell(_ cell: GameCell, atIndexPath indexPath: IndexPath) {
        cell.language = self.dataController.language
        cell.game = self.fetchedResultsController.object(at: indexPath)
    }
}

extension PlayoffGamesController: UITableViewDataSource, UITableViewDelegate {
    
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
        return 172
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let cellIdentifier = "gameCell"
        cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        self.configureCell(cell as! GameCell, atIndexPath:indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedGameId = self.fetchedResultsController.object(at: indexPath).objectId as? Int
        if let _ = self.selectedGameId {
            self.performSegue(withIdentifier: "goToGame", sender: nil)
        }
    }
}

extension PlayoffGamesController: NSFetchedResultsControllerDelegate {
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
