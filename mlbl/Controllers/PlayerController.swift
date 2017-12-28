//
//  PlayerController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 05.09.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import CoreData

class PlayerController: BaseController {
    
    // MARK: - Private
    
    fileprivate enum Sections: Int {
        case title
        case games
        case teams
        case count
    }
    
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var emptyLabel: UILabel!
    fileprivate var refreshButton: UIButton?
    fileprivate var statisticCellOffset = CGPoint.zero
    fileprivate var playerGamesHeader: PlayerGamesHeader?
    fileprivate var selectedGameId: Int?
    fileprivate var isAdjustingScroll = false
    
    fileprivate func setupTableView() {
        self.tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        self.tableView.register(UINib(nibName: "PlayerCell", bundle: nil), forCellReuseIdentifier:"playerCell")
    }
    
    fileprivate func setupPlayer() {
        let fetchRequest = NSFetchRequest<Player>(entityName: Player.entityName())
        fetchRequest.predicate = NSPredicate(format: "objectId = \(self.playerId!)")
        do {
            if let player = try self.dataController.mainContext.fetch(fetchRequest).first {
                self.player = player
            } else {
                _ = self.navigationController?.popViewController(animated: true)
            }
        } catch {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    lazy fileprivate var teamsFetchedResultsController: NSFetchedResultsController<SeasonTeam> = {
        let fetchRequest = NSFetchRequest<SeasonTeam>(entityName: SeasonTeam.entityName())
        fetchRequest.predicate = NSPredicate(format: "player.objectId = \(self.playerId!)")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "abcNameRu", ascending: false)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.dataController.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    lazy fileprivate var statsFetchedResultsController: NSFetchedResultsController<PlayerStatistics> = {
        let fetchRequest = NSFetchRequest<PlayerStatistics>(entityName: PlayerStatistics.entityName())
        fetchRequest.predicate = NSPredicate(format: "player.objectId = \(self.playerId!)")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "game.date", ascending: false)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.dataController.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    fileprivate func getData(_ showIndicator: Bool) {
        if (showIndicator) {
            self.activityView.startAnimating()
            self.tableView.isHidden = true
            self.emptyLabel.isHidden = true
        }
        
        var requestError: NSError?
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        self.dataController.getPlayerTeams(self.playerId) { [weak self] error in
                                            if error == nil {
                                                self?.tableView.reloadSections(IndexSet(integer: Sections.teams.rawValue), with: .none)
                                            }
                                            requestError = error
                                            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        self.dataController.getPlayerStats(self.dataController.currentCompetitionId(), playerId: self.playerId) { [weak self] error in
            if error == nil {
                self?.tableView.reloadSections(IndexSet(integer: Sections.games.rawValue), with: .none)
            }
            requestError = error
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main, execute: { [weak self] in
            if let strongSelf = self {
                strongSelf.activityView.stopAnimating()
                
                if let _ = requestError {
                    strongSelf.emptyLabel.text = requestError?.localizedDescription
                    strongSelf.emptyLabel.isHidden = false
                    strongSelf.tableView.isHidden = true
                    
                    let refreshButton = UIButton(type: .custom)
                    let attrString = NSAttributedString(string: NSLocalizedString("Refresh", comment: ""), attributes: [NSAttributedStringKey.underlineStyle : 1, NSAttributedStringKey.foregroundColor : UIColor.mlblLightOrangeColor()])
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
                    strongSelf.emptyLabel.text = NSLocalizedString("No player info stub", comment: "")
                }
            }
            })
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
    
    fileprivate func configureCell(_ cell: PlayerCell, atIndexPath indexPath: IndexPath) {
        cell.language = self.dataController.language
        cell.player = self.player!
    }
    
    fileprivate func configureCell(_ cell: PlayerGamesCell, atIndexPath indexPath: IndexPath) {
        cell.language = self.dataController.language
        cell.contentOffset = self.statisticCellOffset
        cell.delegate = self
        cell.total = NSLocalizedString("Average", comment: "")
        let fixedIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
        cell.statistics = self.statsFetchedResultsController.object(at: fixedIndexPath)
        cell.color = (indexPath as NSIndexPath).row % 2 == 0 ? UIColor(red: 254/255.0, green: 254/255.0, blue: 254/255.0, alpha: 1) : UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
    }
    
    fileprivate func configureCell(_ cell: PlayerTeamCell, atIndexPath indexPath: IndexPath) {
        cell.language = self.dataController.language
        let fixedIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
        cell.seasonTeam = self.teamsFetchedResultsController.object(at: fixedIndexPath)
        cell.color = (indexPath as NSIndexPath).row % 2 == 0 ? UIColor(red: 254/255.0, green: 254/255.0, blue: 254/255.0, alpha: 1) : UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
    }
    
    // MARK: BaseController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.setupTableView()
        self.setupPlayer()
        
        self.getData(true)
        
        do {
            try self.teamsFetchedResultsController.performFetch()
        } catch {}
        
        do {
            try self.statsFetchedResultsController.performFetch()
        } catch {}
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    }
    
    // MARK: - Public
    
    var playerId: Int!
    var player: Player?

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGame" {
            let gameController = segue.destination as! GameController
            gameController.dataController = self.dataController
            gameController.pushesController = self.pushesController
            gameController.gameId = self.selectedGameId!
        }
    }
}

extension PlayerController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var res: CGFloat = 0.1
        
        if let enumSection = Sections(rawValue: section) {
            switch enumSection {
            case .teams, .games:
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
            case .teams:
                res = PlayerTeamsHeader()
            case .games:
                self.playerGamesHeader = PlayerGamesHeader()
                self.playerGamesHeader?.contentOffset = self.statisticCellOffset
                self.playerGamesHeader?.title = NSLocalizedString("Games", comment: "").uppercased()
                self.playerGamesHeader?.delegate = self
                res = self.playerGamesHeader
            default:
                break
            }
        }
        
        // Чтобы тень от заголовка не падала на сами ячейки
        res?.layer.zPosition = -1
        
        return res
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var res: UIView?
        
        if let enumSection = Sections(rawValue: section) {
            switch enumSection {
            case .teams, .games:
                res = UIView()
                res?.backgroundColor = UIColor.clear
            default:
                break
            }
        }
        
        return res
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var res: CGFloat = 0.1
        
        if let enumSection = Sections(rawValue: section) {
            switch enumSection {
            case .teams:
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
                if let _ = self.player {
                    res = 1
                }
            case .games:
                if let sections = self.statsFetchedResultsController.sections {
                    if let currentSection = sections.first {
                        res = currentSection.numberOfObjects
                    }
                }
            case .teams:
                if let sections = self.teamsFetchedResultsController.sections {
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
                res = 148
            case .games:
                let fixedIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: 0)
                let teamStatistics = self.statsFetchedResultsController.object(at: fixedIndexPath)
                if teamStatistics.game == nil {
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
                cellIdentifier = "playerCell"
            case .games:
                cellIdentifier = "playerGamesCell"
            case .teams:
                cellIdentifier = "playerTeamCell"
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
                self.configureCell(cell as! PlayerCell, atIndexPath:indexPath)
            case .games:
                self.configureCell(cell as! PlayerGamesCell, atIndexPath: indexPath)
            case .teams:
                self.configureCell(cell as! PlayerTeamCell, atIndexPath: indexPath)
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let enumSection = Sections(rawValue: indexPath.section) {
            switch enumSection {
            case .games:
                let fixedIndexPath = IndexPath(row: indexPath.row, section: 0)
                self.selectedGameId = (self.statsFetchedResultsController.object(at: fixedIndexPath)).game?.objectId as? Int
                if let _ = self.selectedGameId {
                    self.performSegue(withIdentifier: "goToGame", sender: nil)
                }
            default:
                break
            }
        }
    }
}

extension PlayerController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ frc: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        var fixedIndexPath: IndexPath?
        var fixedNewIndexPath: IndexPath?
        
        if controller == self.teamsFetchedResultsController {
            if let _ = indexPath {
                fixedIndexPath = IndexPath(row: (indexPath! as NSIndexPath).row, section: Sections.teams.rawValue)
            }
            if let _ = newIndexPath {
                fixedNewIndexPath = IndexPath(row: (newIndexPath! as NSIndexPath).row, section: Sections.teams.rawValue)
            }
        } else if controller == self.statsFetchedResultsController {
            if let _ = indexPath {
                fixedIndexPath = IndexPath(row: (indexPath! as NSIndexPath).row, section: Sections.games.rawValue)
            }
            if let _ = newIndexPath {
                fixedNewIndexPath = IndexPath(row: (newIndexPath! as NSIndexPath).row, section: Sections.games.rawValue)
            }
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

extension PlayerController: PlayerGamesCellDelegate {
    func cell(_ cell: PlayerGamesCell, didScrollTo contentOffset: CGPoint, tag: Int) {
        if !self.isAdjustingScroll {
            self.isAdjustingScroll = true
            
            self.statisticCellOffset = contentOffset
            self.tableView.visibleCells.forEach { cell in
                if let statisticCell = cell as? PlayerGamesCell {
                    statisticCell.contentOffset = contentOffset
                }
            }
            self.playerGamesHeader?.contentOffset = contentOffset
            
            self.isAdjustingScroll = false
        }
    }
}

extension PlayerController: PlayerGamesHeaderDelegate {
    func header(_ header: PlayerGamesHeader, didScrollTo contentOffset: CGPoint) {
        if !self.isAdjustingScroll {
            self.isAdjustingScroll = true
            
            self.statisticCellOffset = contentOffset
            self.tableView.visibleCells.forEach { cell in
                if let statisticCell = cell as? PlayerGamesCell {
                    statisticCell.contentOffset = contentOffset
                }
            }
            
            self.isAdjustingScroll = false
        }
    }
}
