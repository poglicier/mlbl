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
    
    private enum Sections: Int {
        case Title
        case Games
        case Teams
        case Count
    }
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var emptyLabel: UILabel!
    private var refreshButton: UIButton?
    
    private func setupTableView() {
        self.tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        self.tableView.registerNib(UINib(nibName: "PlayerCell", bundle: nil), forCellReuseIdentifier:"playerCell")
    }
    
    private func setupPlayer() {
        let fetchRequest = NSFetchRequest(entityName: Player.entityName())
        fetchRequest.predicate = NSPredicate(format: "objectId = \(self.playerId)")
        do {
            if let player = (try self.dataController.mainContext.executeFetchRequest(fetchRequest)).first as? Player {
                self.player = player
            } else {
                self.navigationController?.popViewControllerAnimated(true)
            }
        } catch {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    lazy private var teamsFetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: SeasonTeam.entityName())
        fetchRequest.predicate = NSPredicate(format: "player.objectId = \(self.playerId)")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "abcNameRu", ascending: false)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.dataController.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        frc.delegate = self
        
        return frc
    }()
    
    private func getData(showIndicator: Bool) {
        if (showIndicator) {
            self.activityView.startAnimating()
            self.tableView.hidden = true
            self.emptyLabel.hidden = true
        }
        
        var requestError: NSError?
        
        let dispatchGroup = dispatch_group_create()
//        dispatch_group_enter(dispatchGroup)
//        self.dataController.getTeamInfo(self.dataController.currentCompetitionId(),
//                                        teamId: self.teamId) { [weak self] error in
//                                            if error == nil {
//                                                self?.tableView.reloadSections(NSIndexSet(index: Sections.Title.rawValue), withRowAnimation: .None)
//                                            }
//                                            requestError = error
//                                            dispatch_group_leave(dispatchGroup)
//        }
//        
        dispatch_group_enter(dispatchGroup)
        self.dataController.getPlayerTeams(self.playerId) { [weak self] error in
                                            if error == nil {
                                                self?.tableView.reloadSections(NSIndexSet(index: Sections.Teams.rawValue), withRowAnimation: .None)
                                            }
                                            requestError = error
                                            dispatch_group_leave(dispatchGroup)
        }
//
//        dispatch_group_enter(dispatchGroup)
//        self.dataController.getTeamGames(self.dataController.currentCompetitionId(),
//                                         teamId: self.teamId) { [weak self] error in
//                                            if error == nil {
//                                                self?.tableView.reloadSections(NSIndexSet(index: Sections.Games.rawValue), withRowAnimation: .None)
//                                            }
//                                            requestError = error
//                                            dispatch_group_leave(dispatchGroup)
//        }
//        
//        dispatch_group_enter(dispatchGroup)
//        self.dataController.getTeamStats(self.dataController.currentCompetitionId(),
//                                         teamId: self.teamId) { [weak self] error in
//                                            if error == nil {
//                                                self?.tableView.reloadSections(NSIndexSet(index: Sections.Statistics.rawValue), withRowAnimation: .None)
//                                            }
//                                            requestError = error
//                                            dispatch_group_leave(dispatchGroup)
//        }
        
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), { [weak self] in
            if let strongSelf = self {
                strongSelf.activityView.stopAnimating()
                
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
                    strongSelf.emptyLabel.text = NSLocalizedString("No player info stub", comment: "")
                }
            }
            })
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
    
    private func configureCell(cell: PlayerCell, atIndexPath indexPath: NSIndexPath) {
        cell.language = self.dataController.language
        cell.player = self.player!
    }
    
    private func configureCell(cell: PlayerGamesCell, atIndexPath indexPath: NSIndexPath) {
        cell.language = self.dataController.language
//        cell.player = self.player!
    }
    
    private func configureCell(cell: PlayerTeamCell, atIndexPath indexPath: NSIndexPath) {
        cell.language = self.dataController.language
        let fixedIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
        cell.seasonTeam = self.teamsFetchedResultsController.objectAtIndexPath(fixedIndexPath) as! SeasonTeam
        cell.color = indexPath.row % 2 == 0 ? UIColor(red: 254/255.0, green: 254/255.0, blue: 254/255.0, alpha: 1) : UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
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
    }
    
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    }
    
    // MARK: - Public
    
    var playerId: Int!
    var player: Player?

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PlayerController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Sections.Count.rawValue
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var res: CGFloat = 0.1
        
        if let enumSection = Sections(rawValue: section) {
            switch enumSection {
            case .Teams:
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
            case .Teams:
                res = PlayerTeamsHeader()
            default:
                break
            }
        }
        
        // Чтобы тень от заголовка не падала на сами ячейки
        res?.layer.zPosition = -1
        
        return res
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var res: UIView?
        
        if let enumSection = Sections(rawValue: section) {
            switch enumSection {
            case .Teams:
                res = UIView()
                res?.backgroundColor = UIColor.clearColor()
            default:
                break
            }
        }
        
        return res
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var res: CGFloat = 0.1
        
        if let enumSection = Sections(rawValue: section) {
            switch enumSection {
            case .Teams:
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
                if let _ = self.player {
                    res = 1
                }
            case .Games:
                return 1
            case .Teams:
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var res: CGFloat = 0
        
        if let enumSection = Sections(rawValue: indexPath.section) {
            switch enumSection {
            case .Title:
                res = 148
            case .Games:
                res = 123
                res += CGFloat((self.player?.gameStatistics?.count ?? 0)*27)
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
                cellIdentifier = "playerCell"
            case .Games:
                cellIdentifier = "playerGamesCell"
            case .Teams:
                cellIdentifier = "playerTeamCell"
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
                self.configureCell(cell as! PlayerCell, atIndexPath:indexPath)
            case .Games:
                self.configureCell(cell as! PlayerGamesCell, atIndexPath: indexPath)
            case .Teams:
                self.configureCell(cell as! PlayerTeamCell, atIndexPath: indexPath)
            default:
                break
            }
        }
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        
//        if let enumSection = Sections(rawValue: indexPath.section) {
//            switch enumSection {
//            case .Players:
//                let fixedIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
//                self.selectedPlayerId = (self.playersFetchedResultsController.objectAtIndexPath(fixedIndexPath) as! Player).objectId as? Int
//                if let _ = self.selectedPlayerId {
//                    self.performSegueWithIdentifier("goToPlayer", sender: nil)
//                }
//            case .Games:
//                let fixedIndexPath = NSIndexPath(forRow: indexPath.row, inSection: 0)
//                self.selectedGameId = (self.gamesFetchedResultsController.objectAtIndexPath(fixedIndexPath) as! Game).objectId as? Int
//                if let _ = self.selectedGameId {
//                    self.performSegueWithIdentifier("goToGame", sender: nil)
//                }
//            //            case .Statistics:
//            default:
//                break
//            }
//        }
//    }
}

extension PlayerController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(frc: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        var fixedIndexPath: NSIndexPath?
        var fixedNewIndexPath: NSIndexPath?
        
        if controller == self.teamsFetchedResultsController {
            if let _ = indexPath {
                fixedIndexPath = NSIndexPath(forRow: indexPath!.row, inSection: Sections.Teams.rawValue)
            }
            if let _ = newIndexPath {
                fixedNewIndexPath = NSIndexPath(forRow: newIndexPath!.row, inSection: Sections.Teams.rawValue)
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