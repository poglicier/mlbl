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

    fileprivate enum Sections: Int {
        case title
        case players
        case games
        case statistics
        case count
    }
    
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var emptyLabel: UILabel!
    
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate var refreshButton: UIButton?
    fileprivate var statisticCellOffset = CGPoint.zero
    fileprivate var teamStatisticsHeader: TeamStatisticsHeader?
    
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
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    }
    
    // MARK: - Private
    fileprivate var selectedPlayerId: Int?
    fileprivate var selectedGameId: Int?
    
    lazy fileprivate var playersFetchedResultsController: NSFetchedResultsController<Player> = {
        let fetchRequest = NSFetchRequest<Player>(entityName: Player.entityName())
        fetchRequest.predicate = NSPredicate(format: "team.objectId = \(self.teamId!)")
        let isLanguageRu = self.dataController.language.contains("ru")
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
    
    lazy fileprivate var gamesFetchedResultsController: NSFetchedResultsController<Game> = {
        let fetchRequest = NSFetchRequest<Game>(entityName: Game.entityName())
        fetchRequest.predicate = NSPredicate(format: "teamAId = \(self.teamId!) OR teamBId = \(self.teamId!)")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.dataController.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    lazy fileprivate var statisticsFetchedResultsController: NSFetchedResultsController<TeamStatistics> = {
        let fetchRequest = NSFetchRequest<TeamStatistics>(entityName: TeamStatistics.entityName())
        fetchRequest.predicate = NSPredicate(format: "team.objectId = \(self.teamId!)")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "playerNumber", ascending: true)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.dataController.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    lazy fileprivate var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-dd-MM"
        return formatter
    } ()
    
    fileprivate func setupTeam() {
        let fetchRequest = NSFetchRequest<Team>(entityName: Team.entityName())
        fetchRequest.predicate = NSPredicate(format: "objectId = \(self.teamId!)")
        do {
            if let team = (try self.dataController.mainContext.fetch(fetchRequest)).first{
                self.team = team
            } else {
                _ = self.navigationController?.popViewController(animated: true)
            }
        } catch {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    fileprivate func setupTableView() {
        self.tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        
        self.refreshControl.tintColor = UIColor.mlblLightOrangeColor()
        self.refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for:.valueChanged)
        self.tableView.addSubview(self.refreshControl)
        self.tableView.sendSubview(toBack: self.refreshControl)
        
        self.tableView.register(UINib(nibName: "StatisticCell", bundle: nil), forCellReuseIdentifier: "statisticCell")
    }
    
    fileprivate func configureCell(_ cell: TeamMainCell, atIndexPath indexPath: IndexPath) {
        cell.language = self.dataController.language
        cell.team = self.team
    }
    
    fileprivate func configureCell(_ cell: TeamPlayerCell, atIndexPath indexPath: IndexPath) {
        cell.language = self.dataController.language
        let fixedIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
        cell.player = self.playersFetchedResultsController.object(at: fixedIndexPath)
        cell.color = (indexPath as NSIndexPath).row % 2 == 0 ? UIColor(red: 254/255.0, green: 254/255.0, blue: 254/255.0, alpha: 1) : UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
        cell.isLast = (indexPath as NSIndexPath).row == (self.team?.players?.count ?? 0) - 1
    }
    
    fileprivate func configureCell(_ cell: TeamGameCell, atIndexPath indexPath: IndexPath) {
        cell.language = self.dataController.language
        cell.dateFormatter = self.dateFormatter
        cell.teamOfInterest = self.team
        let fixedIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
        cell.game = self.gamesFetchedResultsController.object(at: fixedIndexPath)
        cell.color = (indexPath as NSIndexPath).row % 2 == 0 ? UIColor(red: 254/255.0, green: 254/255.0, blue: 254/255.0, alpha: 1) : UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
        cell.isLast = (indexPath as NSIndexPath).row == (self.gamesFetchedResultsController.fetchedObjects?.count ?? 0) - 1
    }
    
    fileprivate func configureCell(_ cell: StatisticCell, atIndexPath indexPath: IndexPath) {
        cell.language = self.dataController.language
        cell.color = (indexPath as NSIndexPath).row % 2 == 0 ? UIColor(red: 254/255.0, green: 254/255.0, blue: 254/255.0, alpha: 1) : UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
        let fixedIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
        cell.total = NSLocalizedString("Average", comment: "").uppercased()
        cell.statistics = self.statisticsFetchedResultsController.object(at: fixedIndexPath)
        cell.selectionStyle = cell.statistics.player == nil ? .none : .default
        cell.contentOffset = self.statisticCellOffset
        cell.delegate = self
    }

    fileprivate func getData(_ showIndicator: Bool) {
        if (showIndicator) {
            self.activityView.startAnimating()
            self.tableView.isHidden = true
            self.emptyLabel.isHidden = true
        }
        
        var requestError: NSError?
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        self.dataController.getTeamInfo(self.dataController.currentCompetitionId(),
            teamId: self.teamId!) { [weak self] error in
                if error == nil {
                    self?.tableView.reloadSections(IndexSet(integer: Sections.title.rawValue), with: .none)
                }
                requestError = error
                dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        self.dataController.getTeamRoster(self.dataController.currentCompetitionId(),
                                          teamId: self.teamId!) { [weak self] error in
                                            if error == nil {
                                                self?.tableView.reloadSections(IndexSet(integer: Sections.players.rawValue), with: .none)
                                            }
                                            requestError = error
                                            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        self.dataController.getTeamGames(self.dataController.currentCompetitionId(),
                                         teamId: self.teamId!) { [weak self] error in
                                            if error == nil {
                                                self?.tableView.reloadSections(IndexSet(integer: Sections.games.rawValue), with: .none)
                                            }
                                            requestError = error
                                            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        self.dataController.getTeamStats(self.dataController.currentCompetitionId(),
                                         teamId: self.teamId!) { [weak self] error in
                                            if error == nil {
                                                self?.tableView.reloadSections(IndexSet(integer: Sections.statistics.rawValue), with: .none)
                                            }
                                            requestError = error
                                            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main, execute: { [weak self] in
            if let strongSelf = self {
                strongSelf.activityView.stopAnimating()
                strongSelf.tableView.layoutIfNeeded()
                strongSelf.refreshControl.endRefreshing()
                
                if let _ = requestError {
                    strongSelf.emptyLabel.text = requestError?.localizedDescription
                    strongSelf.emptyLabel.isHidden = false
                    strongSelf.tableView.isHidden = true
                    
                    let refreshButton = UIButton(type: .custom)
                    let attrString = NSAttributedString(string: NSLocalizedString("Refresh", comment: ""), attributes: [NSUnderlineStyleAttributeName : 1, NSForegroundColorAttributeName : UIColor.mlblLightOrangeColor()])
                    refreshButton.setAttributedTitle(attrString, for: UIControlState())
                    refreshButton.addTarget(self, action: #selector(strongSelf.refreshDidTap), for: .touchUpInside)
                    strongSelf.view.addSubview(refreshButton)
                    
                    refreshButton.snp.makeConstraints({ (make) in
                        make.centerX.equalTo(0)
                        make.top.equalTo(strongSelf.emptyLabel.snp.bottom)
                    })
                    
                    strongSelf.refreshButton = refreshButton
                } else {
                    strongSelf.tableView.isHidden = false
                    strongSelf.emptyLabel.isHidden = strongSelf.tableView.numberOfRows(inSection: 0) > 0
                    strongSelf.emptyLabel.text = NSLocalizedString("No team info stub", comment: "")
                }
            }
            })
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
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGame" {
            let gameController = segue.destination as! GameController
            gameController.dataController = self.dataController
            gameController.gameId = self.selectedGameId!
        } else if segue.identifier == "goToPlayer" {
            let gameController = segue.destination as! PlayerController
            gameController.dataController = self.dataController
            gameController.playerId = self.selectedPlayerId!
        }
    }
}

extension TeamController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var res: CGFloat = 0.1
        
        if let enumSection = Sections(rawValue: section) {
            switch enumSection {
            case .players:
                res = 62
            case .games:
                res = 62
            case .statistics:
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
            switch enumSection {
            case .players:
                res = TeamPlayersHeader()
            case .games:
                res = TeamGamesHeader()
            case .statistics:
                self.teamStatisticsHeader = TeamStatisticsHeader()
                self.teamStatisticsHeader?.contentOffset = self.statisticCellOffset
                self.teamStatisticsHeader?.title = NSLocalizedString("Team statistics", comment: "").uppercased()
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var res: CGFloat = 0.1
        
        if let enumSection = Sections(rawValue: section) {
            switch enumSection {
            case .players:
                res = 4
            case .games:
                res = 4
            case .statistics:
                res = 4
            default:
                break
            }
        }
        
        return res
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var res = 0
        
        if let enumSection = Sections(rawValue: section) {
            switch enumSection {
            case .title:
                if let _ = self.team {
                    res = 1
                }
            case .players:
                if let sections = self.playersFetchedResultsController.sections {
                    if let currentSection = sections.first {
                        res = currentSection.numberOfObjects
                    }
                }
            case .games:
                if let sections = self.gamesFetchedResultsController.sections {
                    if let currentSection = sections.first {
                        res = currentSection.numberOfObjects
                    }
                }
            case .statistics:
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var res: CGFloat = 0
        
        if let enumSection = Sections(rawValue: (indexPath as NSIndexPath).section) {
            switch enumSection {
            case .title:
                res = 180
            case .statistics:
                let fixedIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
                let teamStatistics = self.statisticsFetchedResultsController.object(at: fixedIndexPath)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier: String?
        
        if let enumSection = Sections(rawValue: (indexPath as NSIndexPath).section) {
            switch enumSection {
            case .title:
                cellIdentifier = "teamMainCell"
            case .players:
                cellIdentifier = "teamPlayerCell"
            case .games:
                cellIdentifier = "teamGameCell"
            case .statistics:
                cellIdentifier = "statisticCell"
            default:
                return UITableViewCell()
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier!, for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        if let enumSection = Sections(rawValue: (indexPath as NSIndexPath).section) {
            switch enumSection {
            case .title:
                self.configureCell(cell as! TeamMainCell, atIndexPath:indexPath)
            case .players:
                self.configureCell(cell as! TeamPlayerCell, atIndexPath: indexPath)
            case .games:
                self.configureCell(cell as! TeamGameCell, atIndexPath: indexPath)
            case .statistics:
                self.configureCell(cell as! StatisticCell, atIndexPath: indexPath)
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let enumSection = Sections(rawValue: (indexPath as NSIndexPath).section) {
            let fixedIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
            switch enumSection {
            case .players:
                self.selectedPlayerId = self.playersFetchedResultsController.object(at: fixedIndexPath).objectId as? Int
                if let _ = self.selectedPlayerId {
                    self.performSegue(withIdentifier: "goToPlayer", sender: nil)
                }
            case .games:
                self.selectedGameId = self.gamesFetchedResultsController.object(at: fixedIndexPath).objectId as? Int
                if let _ = self.selectedGameId {
                    self.performSegue(withIdentifier: "goToGame", sender: nil)
                }
            case .statistics:
                if (indexPath as NSIndexPath).row < self.statisticsFetchedResultsController.sections?.first?.numberOfObjects ?? 0 {
                    self.selectedPlayerId = self.statisticsFetchedResultsController.object(at: fixedIndexPath).player?.objectId as? Int
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

extension TeamController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ frc: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        var fixedIndexPath: IndexPath?
        var fixedNewIndexPath: IndexPath?
        
        if controller == self.playersFetchedResultsController {
            if let _ = indexPath {
               fixedIndexPath = IndexPath(row: (indexPath! as NSIndexPath).row, section: Sections.players.rawValue)
            }
            if let _ = newIndexPath {
                fixedNewIndexPath = IndexPath(row: (newIndexPath! as NSIndexPath).row, section: Sections.players.rawValue)
            }
        } else if controller == self.gamesFetchedResultsController {
            if let _ = indexPath {
                fixedIndexPath = IndexPath(row: (indexPath! as NSIndexPath).row, section: Sections.games.rawValue)
            }
            if let _ = newIndexPath {
                fixedNewIndexPath = IndexPath(row: (newIndexPath! as NSIndexPath).row, section: Sections.games.rawValue)
            }
        } else if controller == self.statisticsFetchedResultsController {
            if let _ = indexPath {
                fixedIndexPath = IndexPath(row: (indexPath! as NSIndexPath).row, section: Sections.statistics.rawValue)
            }
            if let _ = newIndexPath {
                fixedNewIndexPath = IndexPath(row: (newIndexPath! as NSIndexPath).row, section: Sections.statistics.rawValue)
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

extension TeamController: StatisticCellDelegate {
    func cell(_ cell: StatisticCell, didScrollTo contentOffset: CGPoint, tag: Int) {
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
    func header(_ header: TeamStatisticsHeader, didScrollTo contentOffset: CGPoint) {
        self.statisticCellOffset = contentOffset
        self.tableView.visibleCells.forEach { cell in
            if let statisticCell = cell as? StatisticCell {
                statisticCell.contentOffset = contentOffset
            }
        }
    }
}
