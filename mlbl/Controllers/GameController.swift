//
//  GameController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 07.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import CoreData

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class GameController: BaseController {

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
        
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidChange(_:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private
    
    fileprivate enum Sections: NSInteger {
        case hat
        case teamA
        case teamB
        case count
    }
    
    var gameId: Int!
    fileprivate var game: Game?
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var webView: UIWebView!
    fileprivate var webViewFailedToLoad = false
    fileprivate var refreshButton: UIButton?
    fileprivate var statisticACellOffset = CGPoint.zero
    fileprivate var teamStatisticsAHeader: TeamStatisticsHeader?
    fileprivate var statisticBCellOffset = CGPoint.zero
    fileprivate var teamStatisticsBHeader: TeamStatisticsHeader?
    fileprivate let teamATag = 1
    fileprivate let teamBTag = 2
    
    lazy fileprivate var statisticsAFetchedResultsController: NSFetchedResultsController<GameStatistics> = {
        let fetchRequest = NSFetchRequest<GameStatistics>(entityName: GameStatistics.entityName())
        fetchRequest.predicate = NSPredicate(format: "game.objectId = \(self.gameId!) AND teamNumber = 1 AND (team != nil OR player != nil)")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "playerNumber", ascending: true)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.dataController.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    lazy fileprivate var statisticsBFetchedResultsController: NSFetchedResultsController<GameStatistics> = {
        let fetchRequest = NSFetchRequest<GameStatistics>(entityName: GameStatistics.entityName())
        fetchRequest.predicate = NSPredicate(format: "game.objectId = \(self.gameId!) AND teamNumber = 2 AND (team != nil OR player != nil)")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "playerNumber", ascending: true)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.dataController.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    fileprivate var selectedPlayerId: Int?
    
    fileprivate func setupTableView() {
        self.tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        
        self.tableView.register(UINib(nibName: "StatisticCell", bundle: nil), forCellReuseIdentifier: "statisticCell")
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Пустая реализация нужна для того, чтобы затереть реализацию BaseController,
        // в которой прячется navigationBar
    }
    
    fileprivate func getData(_ showIndicator: Bool) {
        if !self.webViewFailedToLoad {
            let fetchRequest = NSFetchRequest<Game>(entityName: Game.entityName())
            fetchRequest.predicate = NSPredicate(format: "objectId = \(self.gameId!)")
            do {
                if let intStatus = try self.dataController.mainContext.fetch(fetchRequest).first?.status?.intValue {
                    if let status = Game.GameStatus(rawValue: intStatus) {
                        if status == .online {
                            if let url = URL(string: "http://www.infobasket.ru/stats/game.html?id=\(self.gameId!)&compId=\(self.dataController.currentCompetitionId())&tab=2") {
                                print(url.absoluteString)
                                self.tableView.isHidden = true
                                self.webView.isHidden = true
                                self.webView.loadRequest(URLRequest(url: url))
                                self.activityView.startAnimating()
                                return
                            }
                        }
                    }
                }
                
            } catch {}
        }
        
        if (showIndicator) {
            self.activityView.startAnimating()
            self.tableView.isHidden = true
        }
        
        self.dataController.getGameStats(self.gameId) { [weak self] (error) in
            if let strongSelf = self {
                strongSelf.activityView.stopAnimating()
                
                if let _ = error {
                    strongSelf.tableView.isHidden = true
                    
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error!.userInfo[NSLocalizedDescriptionKey] as? String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    
                    self?.present(alert, animated: true, completion: nil)
                } else {
                    strongSelf.tableView.isHidden = false
                    
                    let fetchRequest = NSFetchRequest<Game>(entityName: Game.entityName())
                    fetchRequest.predicate = NSPredicate(format: "objectId = \(strongSelf.gameId!)")
                    do {
                        strongSelf.game = try strongSelf.dataController.mainContext.fetch(fetchRequest).first
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
    
    fileprivate func configureCell(_ cell: GameScoreCell, atIndexPath indexPath: IndexPath) {
        cell.language = self.dataController.language
        cell.game = self.game
    }
    
    fileprivate func configureCell(_ cell: StatisticCell, atIndexPath indexPath: IndexPath) {
        cell.language = self.dataController.language
        cell.color = (indexPath as NSIndexPath).row % 2 == 0 ? UIColor(red: 254/255.0, green: 254/255.0, blue: 254/255.0, alpha: 1) : UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
        let fixedIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
        
        if (indexPath as NSIndexPath).section == Sections.teamA.rawValue {
            cell.total = NSLocalizedString("Total", comment: "").uppercased()
            cell.gameStatistics = self.statisticsAFetchedResultsController.object(at: fixedIndexPath)
            cell.selectionStyle = cell.gameStatistics.player == nil ? .none : .default
            cell.contentOffset = self.statisticACellOffset
            cell.tag = self.teamATag
        } else if (indexPath as NSIndexPath).section == Sections.teamB.rawValue {
            cell.total = NSLocalizedString("Total", comment: "").uppercased()
            cell.gameStatistics = self.statisticsBFetchedResultsController.object(at: fixedIndexPath)
            cell.selectionStyle = cell.gameStatistics.player == nil ? .none : .default
            cell.contentOffset = self.statisticBCellOffset
            cell.tag = self.teamBTag
        }
        cell.delegate = self
    }
    
    @objc fileprivate func contextDidChange(_ notification: Notification) {
        if (notification.object as? NSManagedObjectContext) == self.dataController.mainContext {
            let inserted = (notification as NSNotification).userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>
            let updated = (notification as NSNotification).userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>
            if (inserted?.filter{ $0 is GameStatistics })?.count > 0 ||
                (updated?.filter{ $0 is GameStatistics })?.count > 0 {
                let fetchRequest = NSFetchRequest<Game>(entityName: Game.entityName())
                fetchRequest.predicate = NSPredicate(format: "objectId = \(self.gameId!)")
                do {
                    self.game = try self.dataController.mainContext.fetch(fetchRequest).first
                } catch {}
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPlayer" {
            let gameController = segue.destination as! PlayerController
            gameController.dataController = self.dataController
            gameController.playerId = self.selectedPlayerId!
        }
    }
}

extension GameController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var res: CGFloat = 0.1
        
        if let enumSection = Sections(rawValue: section) {
            switch enumSection {
            case .teamA:
                res = 62
            case .teamB:
                res = 62
            default:
                break
            }
        }
        
        return res
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var res: UIView?
        
        if let enumSection = Sections(rawValue: section) {
            let isLanguageRu = self.dataController.language.contains("ru")
            
            switch enumSection {
            case .teamA:
                self.teamStatisticsAHeader = TeamStatisticsHeader()
                self.teamStatisticsAHeader?.contentOffset = self.statisticACellOffset
                self.teamStatisticsAHeader?.backgroundColor = self.tableView.backgroundColor
                self.teamStatisticsAHeader?.title = isLanguageRu ? self.game?.teamNameAru : self.game?.teamNameAen
                self.teamStatisticsAHeader?.delegate = self
                res = self.teamStatisticsAHeader
            case .teamB:
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var res: CGFloat = 0.1
        
        if let enumSection = Sections(rawValue: section) {
            switch enumSection {
            case .teamA:
                res = 4
            case .teamB:
                res = 4
            default:
                break
            }
        }
        
        return res
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var res = 0
        
        if self.game == nil {
            res = 0
        } else {
            if let gameSection = Sections(rawValue: section) {
                switch gameSection {
                case .hat:
                    res = 1
                case .teamA:
                    if let sections = self.statisticsAFetchedResultsController.sections {
                        if let currentSection = sections.first {
                            res = currentSection.numberOfObjects
                        }
                    }
                case .teamB:
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var res: CGFloat = 0
        
        if let gameSection = Sections(rawValue: (indexPath as NSIndexPath).section) {
            switch gameSection {
            case .hat:
                res = 252
            case .teamA:
                let fixedIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
                let gameStatistics = self.statisticsAFetchedResultsController.object(at: fixedIndexPath)
                if gameStatistics.player == nil {
                    res = 81
                } else {
                    res = 27
                }
            case .teamB:
                let fixedIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
                let gameStatistics = self.statisticsBFetchedResultsController.object(at: fixedIndexPath)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let gameSection = Sections(rawValue: (indexPath as NSIndexPath).section) {
            switch gameSection {
            case .hat:
                let cellIdentifier = "gameScoreCell"
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            default:
                let cellIdentifier = "statisticCell"
                cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            }
        } else {
            cell = UITableViewCell()
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        if let gameSection = Sections(rawValue: (indexPath as NSIndexPath).section) {
            switch gameSection {
            case .hat:
                self.configureCell(cell as! GameScoreCell, atIndexPath:indexPath)
            default:
                self.configureCell(cell as! StatisticCell, atIndexPath:indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let gameSection = Sections(rawValue: (indexPath as NSIndexPath).section) {
            let fixedIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
            switch gameSection {
            case .teamA:
                if (indexPath as NSIndexPath).row < self.statisticsAFetchedResultsController.sections?.first?.numberOfObjects ?? 0 {
                    self.selectedPlayerId = self.statisticsAFetchedResultsController.object(at: fixedIndexPath).player?.objectId as? Int
                    if let _ = self.selectedPlayerId {
                        self.performSegue(withIdentifier: "goToPlayer", sender: nil)
                    }
                }
            case .teamB:
                if (indexPath as NSIndexPath).row < self.statisticsBFetchedResultsController.sections?.first?.numberOfObjects ?? 0 {
                    self.selectedPlayerId = self.statisticsBFetchedResultsController.object(at: fixedIndexPath).player?.objectId as? Int
                    if let _ = self.selectedPlayerId {
                        self.performSegue(withIdentifier: "goToPlayer", sender: nil)
                    }
                }
            default:
                break
            }
        }
    }
}

extension GameController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ frc: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        var fixedIndexPath: IndexPath?
        var fixedNewIndexPath: IndexPath?
        
        if controller == self.statisticsAFetchedResultsController {
            if let _ = indexPath {
                fixedIndexPath = IndexPath(row: (indexPath! as NSIndexPath).row, section: Sections.teamA.rawValue)
            }
            if let _ = newIndexPath {
                fixedNewIndexPath = IndexPath(row: (newIndexPath! as NSIndexPath).row, section: Sections.teamA.rawValue)
            }
        } else if controller == self.statisticsBFetchedResultsController {
            if let _ = indexPath {
                fixedIndexPath = IndexPath(row: (indexPath! as NSIndexPath).row, section: Sections.teamB.rawValue)
            }
            if let _ = newIndexPath {
                fixedNewIndexPath = IndexPath(row: (newIndexPath! as NSIndexPath).row, section: Sections.teamB.rawValue)
            }
        } else {
            return
        }
        
        switch type {
        case .move:
            self.tableView.deleteRows(at: [fixedIndexPath!], with:.fade)
            self.tableView.insertRows(at: [fixedNewIndexPath!], with:.fade)
        case .insert:
            self.tableView.insertRows(at: [fixedNewIndexPath!], with:.fade)
            
        case .delete:
            self.tableView.deleteRows(at: [fixedIndexPath!], with:.fade)
            
        case .update:
            self.tableView.reloadRows(at: [fixedIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}

extension GameController: StatisticCellDelegate {
    func cell(_ cell: StatisticCell, didScrollTo contentOffset: CGPoint, tag: Int) {
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
    func header(_ header: TeamStatisticsHeader, didScrollTo contentOffset: CGPoint) {
        if header == self.teamStatisticsAHeader {
            self.statisticACellOffset = contentOffset
            self.tableView.indexPathsForVisibleRows?.forEach { indexPath in
                if indexPath.section == Sections.teamA.rawValue {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? StatisticCell {
                        cell.contentOffset = contentOffset
                    }
                }
            }
        } else if header == self.teamStatisticsBHeader {
            self.statisticBCellOffset = contentOffset
            self.tableView.indexPathsForVisibleRows?.forEach { indexPath in
                if indexPath.section == Sections.teamB.rawValue {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? StatisticCell {
                        cell.contentOffset = contentOffset
                    }
                }
            }
        }
    }
}

extension GameController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.webViewFailedToLoad = false
        
        let jsString = "document.readyState"
        let res = self.webView.stringByEvaluatingJavaScript(from: jsString)
        
        if res == "complete" {
            self.webView.isHidden = false
            self.activityView.stopAnimating()
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { [weak self] in
                self?.webViewDidFinishLoad(webView)
            }
        }
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.webViewFailedToLoad = true
        self.getData(true)
    }
}
