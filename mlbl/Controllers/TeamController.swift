//
//  TeamController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 01.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import CoreData

class TeamController: BaseController {

    private enum Sections: Int {
        case Title
        case Players
        case Games
        case Statistics
        case Count
    }
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var emptyLabel: UILabel!
    
    private let refreshControl = UIRefreshControl()
    private var refreshButton: UIButton?
    private var statisticCellOffset = CGPointZero
    private var teamStatisticsHeader: TeamStatisticsHeader?
    
    var teamId: Int!
    var team: Team?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.setupTeam()
        self.setupTableView()
        
        self.getData(true)
        
        do {
            try self.playersFetchedResultsController.performFetch()
        } catch {}
        
        do {
            try self.gamesFetchedResultsController.performFetch()
        } catch {}
        
        do {
            try self.statisticsFetchedResultsController.performFetch()
        } catch {}
    }
    
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    }
    
    // MARK: - Private
    private var selectedPlayerId: Int?
    private var selectedGameId: Int?
    
    lazy private var playersFetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: Player.entityName())
        fetchRequest.predicate = NSPredicate(format: "team.objectId = \(self.teamId)")
        let isLanguageRu = self.dataController.language.containsString("ru")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "playerNumber", ascending: true),
                                        NSSortDescriptor(key: isLanguageRu ? "lastNameRu" : "lastNameEn", ascending: true)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.dataController.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    lazy private var gamesFetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: Game.entityName())
        fetchRequest.predicate = NSPredicate(format: "teamAId = \(self.teamId) OR teamBId = \(self.teamId)")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.dataController.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    lazy private var statisticsFetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: TeamStatistics.entityName())
        fetchRequest.predicate = NSPredicate(format: "team.objectId = \(self.teamId)")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "playerNumber", ascending: true)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.dataController.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    lazy private var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "YYYY-dd-MM"
        return formatter
    } ()
    
    private func setupTeam() {
        let fetchRequest = NSFetchRequest(entityName: Team.entityName())
        fetchRequest.predicate = NSPredicate(format: "objectId = \(self.teamId)")
        do {
            if let team = (try self.dataController.mainContext.executeFetchRequest(fetchRequest)).first as? Team {
                self.team = team
            } else {
                self.navigationController?.popViewControllerAnimated(true)
            }
        } catch {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    private func setupTableView() {
        self.tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        
        self.refreshControl.tintColor = UIColor.mlblLightOrangeColor()
        self.refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), forControlEvents:.ValueChanged)
        self.tableView.addSubview(self.refreshControl)
        self.tableView.sendSubviewToBack(self.refreshControl)
        
        self.tableView.registerNib(UINib(nibName: "StatisticCell", bundle: nil), forCellReuseIdentifier: "statisticCell")
    }
    
    private func configureCell(cell: TeamMainCell, atIndexPath indexPath: NSIndexPath) {
        cell.language = self.dataController.language
        cell.team = self.team
    }
    
    private func configureCell(cell: TeamPlayerCell, atIndexPath indexPath: NSIndexPath) {
        cell.language = self.dataController.language
        let fixedIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
        cell.player = self.playersFetchedResultsController.objectAtIndexPath(fixedIndexPath) as! Player
        cell.color = indexPath.row % 2 == 0 ? UIColor(red: 254/255.0, green: 254/255.0, blue: 254/255.0, alpha: 1) : UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
        cell.isLast = indexPath.row == (self.team?.players?.count ?? 0) - 1
    }
    
    private func configureCell(cell: TeamGameCell, atIndexPath indexPath: NSIndexPath) {
        cell.language = self.dataController.language
        cell.dateFormatter = self.dateFormatter
        cell.teamOfInterest = self.team
        let fixedIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
        cell.game = self.gamesFetchedResultsController.objectAtIndexPath(fixedIndexPath) as! Game
        cell.color = indexPath.row % 2 == 0 ? UIColor(red: 254/255.0, green: 254/255.0, blue: 254/255.0, alpha: 1) : UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
        cell.isLast = indexPath.row == (self.gamesFetchedResultsController.fetchedObjects?.count ?? 0) - 1
    }
    
    private func configureCell(cell: StatisticCell, atIndexPath indexPath: NSIndexPath) {
        cell.language = self.dataController.language
        cell.color = indexPath.row % 2 == 0 ? UIColor(red: 254/255.0, green: 254/255.0, blue: 254/255.0, alpha: 1) : UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
        let fixedIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
        cell.total = NSLocalizedString("Average", comment: "").uppercaseString
        cell.statistics = self.statisticsFetchedResultsController.objectAtIndexPath(fixedIndexPath) as! TeamStatistics
        cell.selectionStyle = cell.statistics.player == nil ? .None : .Default
        cell.contentOffset = self.statisticCellOffset
        cell.delegate = self
    }

    private func getData(showIndicator: Bool) {
        if (showIndicator) {
            self.activityView.startAnimating()
            self.tableView.hidden = true
            self.emptyLabel.hidden = true
        }
        
        var requestError: NSError?
        
        let dispatchGroup = dispatch_group_create()
        dispatch_group_enter(dispatchGroup)
        self.dataController.getTeamInfo(self.dataController.currentCompetitionId(),
            teamId: self.teamId) { [weak self] error in
                if error == nil {
                    self?.tableView.reloadSections(NSIndexSet(index: Sections.Title.rawValue), withRowAnimation: .None)
                }
                requestError = error
                dispatch_group_leave(dispatchGroup)
        }
        
        dispatch_group_enter(dispatchGroup)
        self.dataController.getTeamRoster(self.dataController.currentCompetitionId(),
                                          teamId: self.teamId) { [weak self] error in
                                            if error == nil {
                                                self?.tableView.reloadSections(NSIndexSet(index: Sections.Players.rawValue), withRowAnimation: .None)
                                            }
                                            requestError = error
                                            dispatch_group_leave(dispatchGroup)
        }
        
        dispatch_group_enter(dispatchGroup)
        self.dataController.getTeamGames(self.dataController.currentCompetitionId(),
                                         teamId: self.teamId) { [weak self] error in
                                            if error == nil {
                                                self?.tableView.reloadSections(NSIndexSet(index: Sections.Games.rawValue), withRowAnimation: .None)
                                            }
                                            requestError = error
                                            dispatch_group_leave(dispatchGroup)
        }
        
        dispatch_group_enter(dispatchGroup)
        self.dataController.getTeamStats(self.dataController.currentCompetitionId(),
                                         teamId: self.teamId) { [weak self] error in
                                            if error == nil {
                                                self?.tableView.reloadSections(NSIndexSet(index: Sections.Statistics.rawValue), withRowAnimation: .None)
                                            }
                                            requestError = error
                                            dispatch_group_leave(dispatchGroup)
        }
        
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), { [weak self] in
            if let strongSelf = self {
                strongSelf.activityView.stopAnimating()
                strongSelf.tableView.layoutIfNeeded()
                strongSelf.refreshControl.endRefreshing()
                
                if let _ = requestError {
                    strongSelf.emptyLabel.text = requestError?.localizedDescription
                    strongSelf.emptyLabel.hidden = false
                    strongSelf.tableView.hidden = true
                    
                    let refreshButton = UIButton(type: .Custom)
                    let attrString = NSAttributedString(string: NSLocalizedString("Refresh", comment: ""), attributes: [NSUnderlineStyleAttributeName : 1, NSForegroundColorAttributeName : UIColor.mlblLightOrangeColor()])
                    refreshButton.setAttributedTitle(attrString, forState: .Normal)
                    refreshButton.addTarget(self, action: #selector(strongSelf.refreshDidTap), forControlEvents: .TouchUpInside)
                    strongSelf.view.addSubview(refreshButton)
                    
                    refreshButton.snp_makeConstraints(closure: { (make) in
                        make.centerX.equalTo(0)
                        make.top.equalTo(strongSelf.emptyLabel.snp_bottom)
                    })
                    
                    strongSelf.refreshButton = refreshButton
                } else {
                    strongSelf.tableView.hidden = false
                    strongSelf.emptyLabel.hidden = strongSelf.tableView.numberOfRowsInSection(0) > 0
                    strongSelf.emptyLabel.text = NSLocalizedString("No team info stub", comment: "")
                }
            }
            })
    }
    
    @objc private func handleRefresh(refreshControl: UIRefreshControl) {
        self.getData(false)
    }
    
    @objc private func refreshDidTap(sender: UIButton) {
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
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToGame" {
            let gameController = segue.destinationViewController as! GameController
            gameController.dataController = self.dataController
            gameController.gameId = self.selectedGameId!
        } else if segue.identifier == "goToPlayer" {
            let gameController = segue.destinationViewController as! PlayerController
            gameController.dataController = self.dataController
            gameController.playerId = self.selectedPlayerId!
        }
    }
}

extension TeamController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Sections.Count.rawValue
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var res: CGFloat = 0.1
        
        if let enumSection = Sections(rawValue: section) {
            switch enumSection {
            case .Players:
                res = 62
            case .Games:
                res = 62
            case .Statistics:
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
            switch enumSection {
            case .Players:
                res = TeamPlayersHeader()
            case .Games:
                res = TeamGamesHeader()
            case .Statistics:
                self.teamStatisticsHeader = TeamStatisticsHeader()
                self.teamStatisticsHeader?.contentOffset = self.statisticCellOffset
                self.teamStatisticsHeader?.title = NSLocalizedString("Team statistics", comment: "").uppercaseString
                self.teamStatisticsHeader?.delegate = self
                res = self.teamStatisticsHeader
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
            case .Players:
                res = 4
            case .Games:
                res = 4
            case .Statistics:
                res = 4
            default:
                break
            }
        }
        
        return res
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var res = 0
        
        if let enumSection = Sections(rawValue: section) {
            switch enumSection {
            case .Title:
                if let _ = self.team {
                    res = 1
                }
            case .Players:
                if let sections = self.playersFetchedResultsController.sections {
                    if let currentSection = sections.first {
                        res = currentSection.numberOfObjects
                    }
                }
            case .Games:
                if let sections = self.gamesFetchedResultsController.sections {
                    if let currentSection = sections.first {
                        res = currentSection.numberOfObjects
                    }
                }
            case .Statistics:
                if let sections = self.statisticsFetchedResultsController.sections {
                    if let currentSection = sections.first {
                        res = currentSection.numberOfObjects
                    }
                }
            default:
                break
            }
        }
        
        return res
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var res: CGFloat = 0
        
        if let enumSection = Sections(rawValue: indexPath.section) {
            switch enumSection {
            case .Title:
                res = 180
            case .Statistics:
                let fixedIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
                let teamStatistics = self.statisticsFetchedResultsController.objectAtIndexPath(fixedIndexPath) as! TeamStatistics
                if teamStatistics.player == nil {
                    res = 54
                } else {
                    res = 27
                }
            default:
                res = 27
            }
        }
        return res
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier: String?
        
        if let enumSection = Sections(rawValue: indexPath.section) {
            switch enumSection {
            case .Title:
                cellIdentifier = "teamMainCell"
            case .Players:
                cellIdentifier = "teamPlayerCell"
            case .Games:
                cellIdentifier = "teamGameCell"
            case .Statistics:
                cellIdentifier = "statisticCell"
            default:
                return UITableViewCell()
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier!, forIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        
        if let enumSection = Sections(rawValue: indexPath.section) {
            switch enumSection {
            case .Title:
                self.configureCell(cell as! TeamMainCell, atIndexPath:indexPath)
            case .Players:
                self.configureCell(cell as! TeamPlayerCell, atIndexPath: indexPath)
            case .Games:
                self.configureCell(cell as! TeamGameCell, atIndexPath: indexPath)
            case .Statistics:
                self.configureCell(cell as! StatisticCell, atIndexPath: indexPath)
            default:
                break
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let enumSection = Sections(rawValue: indexPath.section) {
            let fixedIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
            switch enumSection {
            case .Players:
                self.selectedPlayerId = (self.playersFetchedResultsController.objectAtIndexPath(fixedIndexPath) as! Player).objectId as? Int
                if let _ = self.selectedPlayerId {
                    self.performSegueWithIdentifier("goToPlayer", sender: nil)
                }
            case .Games:
                self.selectedGameId = (self.gamesFetchedResultsController.objectAtIndexPath(fixedIndexPath) as! Game).objectId as? Int
                if let _ = self.selectedGameId {
                    self.performSegueWithIdentifier("goToGame", sender: nil)
                }
            case .Statistics:
                if indexPath.row < self.statisticsFetchedResultsController.sections?.first?.numberOfObjects ?? 0 {
                    self.selectedPlayerId = (self.statisticsFetchedResultsController.objectAtIndexPath(fixedIndexPath) as! TeamStatistics).player?.objectId as? Int
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

extension TeamController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(frc: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        var fixedIndexPath: NSIndexPath?
        var fixedNewIndexPath: NSIndexPath?
        
        if controller == self.playersFetchedResultsController {
            if let _ = indexPath {
               fixedIndexPath = NSIndexPath(forRow: indexPath!.row, inSection: Sections.Players.rawValue)
            }
            if let _ = newIndexPath {
                fixedNewIndexPath = NSIndexPath(forRow: newIndexPath!.row, inSection: Sections.Players.rawValue)
            }
        } else if controller == self.gamesFetchedResultsController {
            if let _ = indexPath {
                fixedIndexPath = NSIndexPath(forRow: indexPath!.row, inSection: Sections.Games.rawValue)
            }
            if let _ = newIndexPath {
                fixedNewIndexPath = NSIndexPath(forRow: newIndexPath!.row, inSection: Sections.Games.rawValue)
            }
        } else if controller == self.statisticsFetchedResultsController {
            if let _ = indexPath {
                fixedIndexPath = NSIndexPath(forRow: indexPath!.row, inSection: Sections.Statistics.rawValue)
            }
            if let _ = newIndexPath {
                fixedNewIndexPath = NSIndexPath(forRow: newIndexPath!.row, inSection: Sections.Statistics.rawValue)
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

extension TeamController: StatisticCellDelegate {
    func cell(cell: StatisticCell, didScrollTo contentOffset: CGPoint, tag: Int) {
        self.statisticCellOffset = contentOffset
        self.tableView.visibleCells.forEach { cell in
            if let statisticCell = cell as? StatisticCell {
                statisticCell.contentOffset = contentOffset
            }
        }
        self.teamStatisticsHeader?.contentOffset = contentOffset
    }
}

extension TeamController: TeamStatisticsHeaderDelegate {
    func header(header: TeamStatisticsHeader, didScrollTo contentOffset: CGPoint) {
        self.statisticCellOffset = contentOffset
        self.tableView.visibleCells.forEach { cell in
            if let statisticCell = cell as? StatisticCell {
                statisticCell.contentOffset = contentOffset
            }
        }
    }
}