//
//  GameController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 07.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import CoreData

class GameController: BaseController {
    private enum Sections: NSInteger {
        case Hat
        case TeamA
        case TeamB
        case Count
    }
    
    var gameId: Int!
    private var game: Game?
    @IBOutlet private var tableView: UITableView!
    private var refreshButton: UIButton?
    private var statisticACellOffset = CGPointZero
    private var teamStatisticsAHeader: TeamStatisticsHeader?
    private var statisticBCellOffset = CGPointZero
    private var teamStatisticsBHeader: TeamStatisticsHeader?
    private let teamATag = 1
    private let teamBTag = 2

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.automaticallyAdjustsScrollViewInsets = false
        self.setupTableView()
        
        self.getData(true)
        
        do {
            try self.statisticsAFetchedResultsController.performFetch()
        } catch {}
        do {
            try self.statisticsBFetchedResultsController.performFetch()
        } catch {}
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(contextDidChange(_:)), name: NSManagedObjectContextObjectsDidChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Private
    
    lazy private var statisticsAFetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: GameStatistics.entityName())
        fetchRequest.predicate = NSPredicate(format: "game.objectId = \(self.gameId) AND teamNumber = 1")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "playerNumber", ascending: true)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.dataController.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    lazy private var statisticsBFetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: GameStatistics.entityName())
        fetchRequest.predicate = NSPredicate(format: "game.objectId = \(self.gameId) AND teamNumber = 2")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "playerNumber", ascending: true)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.dataController.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    private var selectedPlayerId: Int?
    
    private func setupTableView() {
        self.tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        
        self.tableView.registerNib(UINib(nibName: "StatisticCell", bundle: nil), forCellReuseIdentifier: "statisticCell")
    }
    
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Пустая реализация нужна для того, чтобы затереть реализацию BaseController,
        // в которой прячется navigationBar
    }
    
    private func getData(showIndicator: Bool) {
        if (showIndicator) {
            self.activityView.startAnimating()
            self.tableView.hidden = true
        }
        
        self.dataController.getGameStats(self.gameId) { [weak self] (error) in
            if let strongSelf = self {
                strongSelf.activityView.stopAnimating()
                
                if let _ = error {
                    strongSelf.tableView.hidden = true
                    
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error!.userInfo[NSLocalizedDescriptionKey] as? String, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
                    
                    self?.presentViewController(alert, animated: true, completion: nil)
                } else {
                    strongSelf.tableView.hidden = false
                    
                    let fetchRequest = NSFetchRequest(entityName: Game.entityName())
                    fetchRequest.predicate = NSPredicate(format: "objectId = \(strongSelf.gameId)")
                    do {
                        strongSelf.game = try strongSelf.dataController.mainContext.executeFetchRequest(fetchRequest).first as? Game
                    } catch {}
                    strongSelf.tableView.reloadData()
                }
            }
        }
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
    
    private func configureCell(cell: GameScoreCell, atIndexPath indexPath: NSIndexPath) {
        cell.language = self.dataController.language
        cell.game = self.game
    }
    
    private func configureCell(cell: StatisticCell, atIndexPath indexPath: NSIndexPath) {
        cell.language = self.dataController.language
        cell.color = indexPath.row % 2 == 0 ? UIColor(red: 254/255.0, green: 254/255.0, blue: 254/255.0, alpha: 1) : UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
        let fixedIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
        
        if indexPath.section == Sections.TeamA.rawValue {
            cell.total = NSLocalizedString("Total", comment: "").uppercaseString
            cell.gameStatistics = self.statisticsAFetchedResultsController.objectAtIndexPath(fixedIndexPath) as! GameStatistics
            cell.selectionStyle = cell.gameStatistics.player == nil ? .None : .Default
            cell.contentOffset = self.statisticACellOffset
            cell.tag = self.teamATag
        } else if indexPath.section == Sections.TeamB.rawValue {
            cell.total = NSLocalizedString("Total", comment: "").uppercaseString
            cell.gameStatistics = self.statisticsBFetchedResultsController.objectAtIndexPath(fixedIndexPath) as! GameStatistics
            cell.selectionStyle = cell.gameStatistics.player == nil ? .None : .Default
            cell.contentOffset = self.statisticBCellOffset
            cell.tag = self.teamBTag
        }
        cell.delegate = self
    }
    
    @objc private func contextDidChange(notification: NSNotification) {
        if (notification.object as? NSManagedObjectContext) == self.dataController.mainContext {
            let inserted = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>
            let updated = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>
            if (inserted?.filter{ $0 is GameStatistics })?.count > 0 ||
                (updated?.filter{ $0 is GameStatistics })?.count > 0 {
                let fetchRequest = NSFetchRequest(entityName: Game.entityName())
                fetchRequest.predicate = NSPredicate(format: "objectId = \(self.gameId)")
                do {
                    self.game = try self.dataController.mainContext.executeFetchRequest(fetchRequest).first as? Game
                } catch {}
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToPlayer" {
            let gameController = segue.destinationViewController as! PlayerController
            gameController.dataController = self.dataController
            gameController.playerId = self.selectedPlayerId!
        }
    }
}

extension GameController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Sections.Count.rawValue
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var res: CGFloat = 0.1
        
        if let enumSection = Sections(rawValue: section) {
            switch enumSection {
            case .TeamA:
                res = 62
            case .TeamB:
                res = 62
            default:
                break
            }
        }
        
        return res
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var res: UIView?
        
        if let enumSection = Sections(rawValue: section) {
            let isLanguageRu = self.dataController.language.containsString("ru")
            
            switch enumSection {
            case .TeamA:
                self.teamStatisticsAHeader = TeamStatisticsHeader()
                self.teamStatisticsAHeader?.contentOffset = self.statisticACellOffset
                self.teamStatisticsAHeader?.backgroundColor = self.tableView.backgroundColor
                self.teamStatisticsAHeader?.title = isLanguageRu ? self.game?.teamNameAru : self.game?.teamNameAen
                self.teamStatisticsAHeader?.delegate = self
                res = self.teamStatisticsAHeader
            case .TeamB:
                self.teamStatisticsBHeader = TeamStatisticsHeader()
                self.teamStatisticsBHeader?.contentOffset = self.statisticBCellOffset
                self.teamStatisticsBHeader?.backgroundColor = self.tableView.backgroundColor
                self.teamStatisticsBHeader?.title = isLanguageRu ? self.game?.teamNameBru : self.game?.teamNameBen
                self.teamStatisticsBHeader?.delegate = self
                res = self.teamStatisticsBHeader
            default:
                break
            }
        }
        
        // Чтобы тень от заголовка не падала на сами ячейки
        res?.layer.zPosition = -1
        
        return res
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var res: CGFloat = 0.1
        
        if let enumSection = Sections(rawValue: section) {
            switch enumSection {
            case .TeamA:
                res = 4
            case .TeamB:
                res = 4
            default:
                break
            }
        }
        
        return res
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var res = 0
        
        if self.game == nil {
            res = 0
        } else {
            if let gameSection = Sections(rawValue: section) {
                switch gameSection {
                case .Hat:
                    res = 1
                case .TeamA:
                    if let sections = self.statisticsAFetchedResultsController.sections {
                        if let currentSection = sections.first {
                            res = currentSection.numberOfObjects
                        }
                    }
                case .TeamB:
                    if let sections = self.statisticsBFetchedResultsController.sections {
                        if let currentSection = sections.first {
                            res = currentSection.numberOfObjects
                        }
                    }
                default:
                    res = 0
                }
            }
        }
        
        return res
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var res: CGFloat = 0
        
        if let gameSection = Sections(rawValue: indexPath.section) {
            switch gameSection {
            case .Hat:
                res = 252
            case .TeamA:
                let fixedIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
                let gameStatistics = self.statisticsAFetchedResultsController.objectAtIndexPath(fixedIndexPath) as! GameStatistics
                if gameStatistics.player == nil {
                    res = 81
                } else {
                    res = 27
                }
            case .TeamB:
                let fixedIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
                let gameStatistics = self.statisticsBFetchedResultsController.objectAtIndexPath(fixedIndexPath) as! GameStatistics
                if gameStatistics.player == nil {
                    res = 81
                } else {
                    res = 27
                }
            default:
                res = 27
            }
        }
//        if indexPath.section == Sections.Hat.rawValue {
//            res = 252
//        } else {
//            if let statistics = ((self.game?.statistics as? Set<GameStatistics>)?.filter {$0.teamNumber?.integerValue == indexPath.section && $0.player != nil }) {
//                res += CGFloat((statistics.count)*27)
//            }
//        }
        
        return res
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let gameSection = Sections(rawValue: indexPath.section) {
            switch gameSection {
            case .Hat:
                let cellIdentifier = "gameScoreCell"
                cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
            default:
                let cellIdentifier = "statisticCell"
                cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
            }
        } else {
            cell = UITableViewCell()
        }
        
        return cell
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        
        if let gameSection = Sections(rawValue: indexPath.section) {
            switch gameSection {
            case .Hat:
                self.configureCell(cell as! GameScoreCell, atIndexPath:indexPath)
            default:
                self.configureCell(cell as! StatisticCell, atIndexPath:indexPath)
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let gameSection = Sections(rawValue: indexPath.section) {
            let fixedIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
            switch gameSection {
            case .TeamA:
                if indexPath.row < self.statisticsAFetchedResultsController.sections?.first?.numberOfObjects ?? 0 {
                    self.selectedPlayerId = (self.statisticsAFetchedResultsController.objectAtIndexPath(fixedIndexPath) as! GameStatistics).player?.objectId as? Int
                    if let _ = self.selectedPlayerId {
                        self.performSegueWithIdentifier("goToPlayer", sender: nil)
                    }
                }
            case .TeamB:
                if indexPath.row < self.statisticsBFetchedResultsController.sections?.first?.numberOfObjects ?? 0 {
                    self.selectedPlayerId = (self.statisticsBFetchedResultsController.objectAtIndexPath(fixedIndexPath) as! GameStatistics).player?.objectId as? Int
                    if let _ = self.selectedPlayerId {
                        self.performSegueWithIdentifier("goToPlayer", sender: nil)
                    }
                }
            default:
                break
            }
        }
    }
}

extension GameController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(frc: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        var fixedIndexPath: NSIndexPath?
        var fixedNewIndexPath: NSIndexPath?
        
        if controller == self.statisticsAFetchedResultsController {
            if let _ = indexPath {
                fixedIndexPath = NSIndexPath(forRow: indexPath!.row, inSection: Sections.TeamA.rawValue)
            }
            if let _ = newIndexPath {
                fixedNewIndexPath = NSIndexPath(forRow: newIndexPath!.row, inSection: Sections.TeamA.rawValue)
            }
        } else if controller == self.statisticsBFetchedResultsController {
            if let _ = indexPath {
                fixedIndexPath = NSIndexPath(forRow: indexPath!.row, inSection: Sections.TeamB.rawValue)
            }
            if let _ = newIndexPath {
                fixedNewIndexPath = NSIndexPath(forRow: newIndexPath!.row, inSection: Sections.TeamB.rawValue)
            }
        } else {
            return
        }
        
        switch type {
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([fixedIndexPath!], withRowAnimation:.Fade)
            self.tableView.insertRowsAtIndexPaths([fixedNewIndexPath!], withRowAnimation:.Fade)
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([fixedNewIndexPath!], withRowAnimation:.Fade)
            
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([fixedIndexPath!], withRowAnimation:.Fade)
            
        case .Update:
            self.tableView.reloadRowsAtIndexPaths([fixedIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(_: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}

extension GameController: StatisticCellDelegate {
    func cell(cell: StatisticCell, didScrollTo contentOffset: CGPoint, tag: Int) {
        if tag == self.teamATag {
            self.statisticACellOffset = contentOffset
            self.tableView.visibleCells.forEach { cell in
                if let statisticCell = cell as? StatisticCell {
                    if statisticCell.tag == tag {
                        statisticCell.contentOffset = contentOffset
                    }
                }
            }
            self.teamStatisticsAHeader?.contentOffset = contentOffset
        } else if tag == self.teamBTag {
            self.statisticBCellOffset = contentOffset
            self.tableView.visibleCells.forEach { cell in
                if let statisticCell = cell as? StatisticCell {
                    if statisticCell.tag == tag {
                        statisticCell.contentOffset = contentOffset
                    }
                }
            }
            self.teamStatisticsBHeader?.contentOffset = contentOffset
        }
    }
}

extension GameController: TeamStatisticsHeaderDelegate {
    func header(header: TeamStatisticsHeader, didScrollTo contentOffset: CGPoint) {
        if header == self.teamStatisticsAHeader {
            self.statisticACellOffset = contentOffset
            self.tableView.indexPathsForVisibleRows?.forEach { indexPath in
                if indexPath.section == Sections.TeamA.rawValue {
                    (self.tableView.cellForRowAtIndexPath(indexPath) as? StatisticCell)?.contentOffset = contentOffset
                }
            }
        } else if header == self.teamStatisticsBHeader {
            self.statisticBCellOffset = contentOffset
            self.tableView.indexPathsForVisibleRows?.forEach { indexPath in
                if indexPath.section == Sections.TeamB.rawValue {
                    (self.tableView.cellForRowAtIndexPath(indexPath) as? StatisticCell)?.contentOffset = contentOffset
                }
            }
        }
    }
}