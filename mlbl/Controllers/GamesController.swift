//
//  GamesController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 05.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

class GamesController: BaseController {
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var dateLabel: UILabel!
    @IBOutlet fileprivate var emptyLabel: UILabel!
    @IBOutlet fileprivate var datesView: UIView!
    @IBOutlet fileprivate var prevButton: UIButton!
    @IBOutlet fileprivate var nextButton: UIButton!
    @IBOutlet fileprivate var tableViewCenterX: NSLayoutConstraint!
    
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate var refreshButton: UIButton?
    fileprivate var selectedGameId: Int?
    fileprivate var prevDate: Date?
    fileprivate var currentDate: Date? {
        didSet {
            if let _ = currentDate {
                self.dateLabel.text = self.dateFormatter.string(from: currentDate!)
            } else {
                self.dateLabel.text = nil
            }
        }
    }
    fileprivate var nextDate: Date?
    
    lazy fileprivate var dateFormatter: DateFormatter = {
        let res = DateFormatter()
        res.dateFormat = "dd.MM.yyyy"
        res.dateStyle = .short
        return res
    }()
    
    lazy fileprivate var fetchedResultsController: NSFetchedResultsController<Game> = {
        let fetchRequest = NSFetchRequest<Game>(entityName: Game.entityName())
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
        self.getData(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidChange(_:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    @objc fileprivate func contextDidChange(_ notification: Notification) {
        if (notification.object as? NSManagedObjectContext) == self.dataController.mainContext {
            let inserted = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>
            if (inserted?.contains(where: { $0 is Game }) ?? false) {
                self.updateGamesStatuses()
            } else {
                let updated = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>
                if (updated?.contains( where: { $0 is Game }) ?? false) {
                    self.updateGamesStatuses()
                }
            }
        }
    }
    
    fileprivate func setupDate() {
        self.currentDate = Date()
    }
    
    fileprivate func setupButtons() {
        self.prevButton.isEnabled = false
        self.nextButton.isEnabled = false
    }
    
    fileprivate func setupEmptyLabel() {
        self.emptyLabel.text = NSLocalizedString("No games stub", comment: "")
        self.emptyLabel.isHidden = true
    }
    
    fileprivate func getData(_ showIndicator: Bool) {
        if let date = self.currentDate {
            if (showIndicator) {
                self.activityView.startAnimating()
                self.tableView.isHidden = true
                self.emptyLabel.isHidden = true
            }

            let dates = self.datesIntervalForDate(date)
            self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "date > %@ AND date < %@", dates.0 as CVarArg, dates.1 as CVarArg)
            
            do {
                try self.fetchedResultsController.performFetch()
            } catch {}
            self.tableView.reloadData()
            
            self.dataController.getGamesForDate(date) { [weak self] (error, newPrevDate, newNextDate) in
                if let strongSelf = self {
                    strongSelf.tableView.layoutIfNeeded()
                    strongSelf.refreshControl.endRefreshing()
                    
                    strongSelf.activityView.stopAnimating()

                    if let _ = error {
                        strongSelf.prevButton.isEnabled = strongSelf.prevDate != nil
                        strongSelf.nextButton.isEnabled = strongSelf.nextDate != nil
                        strongSelf.emptyLabel.text = error?.localizedDescription
                        strongSelf.tableView.isHidden = true
                        strongSelf.emptyLabel.isHidden = false
                        
                        let refreshButton = UIButton(type: .custom)
                        let attrString = NSAttributedString(string: NSLocalizedString("Refresh", comment: ""), attributes: [NSAttributedStringKey.underlineStyle : 1, NSAttributedStringKey.foregroundColor : UIColor.mlblLightOrangeColor()])
                        refreshButton.setAttributedTitle(attrString, for: .normal)
                        refreshButton.addTarget(self, action: #selector(strongSelf.refreshDidTap), for: .touchUpInside)
                        strongSelf.view.addSubview(refreshButton)
                        
                        refreshButton.snp.makeConstraints( { (make) in
                            make.centerX.equalTo(0)
                            make.top.equalTo(strongSelf.emptyLabel.snp.bottom)
                        })
                        
                        strongSelf.refreshButton = refreshButton
                    } else {
                        strongSelf.tableView.isHidden = false
                        strongSelf.emptyLabel.isHidden = strongSelf.tableView.numberOfRows(inSection: 0) > 0
                        strongSelf.prevButton.isEnabled = newPrevDate != nil
                        strongSelf.nextButton.isEnabled = newNextDate != nil
                        strongSelf.emptyLabel.text = NSLocalizedString("No games stub", comment: "")
                        
                        strongSelf.prevDate = newPrevDate
                        strongSelf.nextDate = newNextDate
                    }
                }
            }
        }
    }
    
    fileprivate func updateGamesStatuses() {
        if let games = self.fetchedResultsController.fetchedObjects {
            var gameIds = [Int]()
            
            for game in games {
                if let gameId = game.objectId?.intValue {
                    gameIds.append(gameId)
                }
            }
            
            self.dataController.getGamesOnlineStatuses(gameIds: gameIds, completion: nil)
        }
    }
    
    fileprivate func setupTableView() {
        self.tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        self.tableView.register(UINib(nibName: "GameCell", bundle: nil), forCellReuseIdentifier: "gameCell");
        
        self.refreshControl.tintColor = UIColor.mlblLightOrangeColor()
        self.refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for:.valueChanged)
        self.tableView.addSubview(self.refreshControl)
        self.tableView.sendSubview(toBack: self.refreshControl)
    }
    
    fileprivate func configureCell(_ cell: GameCell, atIndexPath indexPath: IndexPath) {
        cell.language = self.dataController.language
        cell.game = self.fetchedResultsController.object(at: indexPath)
    }
    
    @objc fileprivate func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getData(false)
    }
    
    @objc fileprivate func refreshDidTap(_ sender: UIButton) {
        self.refreshButton?.removeFromSuperview()
        self.refreshButton = nil
        self.getData(true)
    }
    
    override func willEnterForegroud() {
        if let _ = self.refreshButton {
            self.refreshButton?.removeFromSuperview()
            self.refreshButton = nil
            self.getData(true)
        } else {
            self.getData(false)
        }
    }
    
    @IBAction fileprivate func goToPrevDate() {
        self.currentDate = self.prevDate
        
        self.prevButton.isEnabled = false
        self.nextButton.isEnabled = false
        
        self.tableViewCenterX.constant = self.tableView.frame.size.width
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            }, completion: { (Bool) in
                self.tableViewCenterX.constant = 0
                self.view.layoutIfNeeded()
                
                self.getData(true)
            }) 
    }
    
    @IBAction fileprivate func goToNextDate() {
        self.currentDate = self.nextDate
        
        self.prevButton.isEnabled = false
        self.nextButton.isEnabled = false
        
        self.tableViewCenterX.constant = -self.tableView.frame.size.width
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
            self.tableViewCenterX.constant = 0
            self.view.layoutIfNeeded()
            
            self.getData(true)
        }) 
    }
    
    fileprivate func datesIntervalForDate(_ date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        var components = (calendar as NSCalendar).components([.year, .month, .day], from:date)
        let startDate = calendar.date(from: components)
        components.day = (components.day ?? -1) + 1
        let endDate = calendar.date(from: components)
        
        return (startDate!, endDate!)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGame" {
            let gameController = segue.destination as! GameController
            gameController.dataController = self.dataController
            gameController.gameId = self.selectedGameId!
        }
    }
}

extension GamesController: NSFetchedResultsControllerDelegate {
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

extension GamesController: UITableViewDataSource, UITableViewDelegate {
    
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
        let game = self.fetchedResultsController.object(at: indexPath)
        self.selectedGameId = game.objectId as? Int
        
        if let _ = self.selectedGameId {
            self.performSegue(withIdentifier: "goToGame", sender: nil)
        }
    }
}
