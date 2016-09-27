//
//  TableController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 18.07.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import CoreData

class TableController: BaseController {
    @IBOutlet fileprivate var roundTableView: UITableView!
    @IBOutlet fileprivate var playoffTableView: UITableView!
    @IBOutlet fileprivate var emptyLabel: UILabel!
    @IBOutlet fileprivate var stageSelectorView: UIView!
    @IBOutlet fileprivate var stageLabel: UILabel!
    @IBOutlet fileprivate var nextButton: UIButton!
    @IBOutlet fileprivate var prevButton: UIButton!
    
    fileprivate let refreshControlRound = UIRefreshControl()
    fileprivate let refreshControlPlayoff = UIRefreshControl()
    fileprivate var refreshButtonRound: UIButton?
    fileprivate var refreshButtonPlayoff: UIButton?
    fileprivate var selectedGameId: Int?
    fileprivate var selectedGameIds: [Int]?
    fileprivate var selectedTeamId: Int?
    fileprivate let rowHeight: CGFloat = 112
    fileprivate let playoffRowHeight: CGFloat = 180
    fileprivate var childrenComptetitions = [Competition]()
    fileprivate var selectedCompetition: Competition! {
        didSet {
            let isLanguageRu = self.dataController.language.contains("ru")
            self.stageLabel.text = isLanguageRu ? selectedCompetition.compShortNameRu : selectedCompetition.compShortNameEn
            
            self.refreshButtonPlayoff?.removeFromSuperview()
            self.refreshButtonPlayoff = nil
            self.refreshButtonRound?.removeFromSuperview()
            self.refreshButtonRound = nil
            
            if selectedCompetition.compType?.intValue ?? -1 == 0 {
                self.getRoundRobin(true)
                
                self.roundTableView.scrollsToTop = true
                self.playoffTableView.scrollsToTop = false
                self.roundTableView.contentOffset = CGPoint(x: 0, y: -4)
                self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "competition = %@", self.selectedCompetition)
                do {
                    try self.fetchedResultsController.performFetch()
                } catch {}
                self.roundTableView.reloadData()
            } else {
                self.getPlayoff(true)
                
                self.roundTableView.scrollsToTop = false
                self.playoffTableView.scrollsToTop = true
                self.playoffTableView.contentOffset = CGPoint.zero
                self.playoffFetchedResultsController.fetchRequest.predicate = NSPredicate(format: "competition = %@", self.selectedCompetition)
                do {
                    try self.playoffFetchedResultsController.performFetch()
                } catch {}
                self.playoffTableView.reloadData()
            }
        }
    }
    
    lazy fileprivate var fetchedResultsController: NSFetchedResultsController<TeamRoundRank> = {
        let fetchRequest = NSFetchRequest<TeamRoundRank>(entityName: TeamRoundRank.entityName())
        fetchRequest.predicate = NSPredicate(format: "competition = %@", self.selectedCompetition)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "place", ascending: true)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.dataController.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        frc.delegate = self
        
        return frc
    }()
    
    lazy fileprivate var playoffFetchedResultsController: NSFetchedResultsController<PlayoffSerie> = {
        let fetchRequest = NSFetchRequest<PlayoffSerie>(entityName: PlayoffSerie.entityName())
        fetchRequest.predicate = NSPredicate(format: "competition = %@", self.selectedCompetition)
        let isLanguageRu = self.dataController.language.contains("ru")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "sectionSort", ascending: true),
                                        NSSortDescriptor(key: "sort", ascending: true)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.dataController.mainContext,
            sectionNameKeyPath: "sectionSort",
            cacheName: nil)
        frc.delegate = self
        
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTableViews()
        self.setupSubcompetitions()
    }
    
    // MARK: - Private

    fileprivate func setupTableViews() {
        self.roundTableView.contentInset = UIEdgeInsetsMake(4, 0, 4, 0)
        
        self.refreshControlRound.tintColor = UIColor.mlblLightOrangeColor()
        self.refreshControlRound.addTarget(self, action: #selector(handleRefreshRound(_:)), for:.valueChanged)
        self.roundTableView.addSubview(self.refreshControlRound)
        self.roundTableView.sendSubview(toBack: self.refreshControlRound)
        
        self.refreshControlPlayoff.tintColor = UIColor.mlblLightOrangeColor()
        self.refreshControlPlayoff.addTarget(self, action: #selector(handleRefreshPlayoff(_:)), for:.valueChanged)
        self.playoffTableView.addSubview(self.refreshControlPlayoff)
        self.playoffTableView.sendSubview(toBack: self.refreshControlPlayoff)
    }
    
    @objc fileprivate func handleRefreshRound(_ refreshControl: UIRefreshControl) {
        self.getRoundRobin(false)
    }
    
    @objc fileprivate func handleRefreshPlayoff(_ refreshControl: UIRefreshControl) {
        self.getPlayoff(false)
    }
    
    override func willEnterForegroud() {
        if selectedCompetition.compType?.intValue ?? -1 == 0 {
            if let _ = self.refreshButtonRound {
                self.refreshButtonRound?.removeFromSuperview()
                self.refreshButtonRound = nil
                self.getRoundRobin(true)
            } else {
                self.getRoundRobin(false)
            }
        } else {
            if let _ = self.refreshButtonPlayoff {
                self.refreshButtonPlayoff?.removeFromSuperview()
                self.refreshButtonPlayoff = nil
                self.getPlayoff(true)
            } else {
                self.getPlayoff(false)
            }
        }
    }
    
    fileprivate func setupSubcompetitions() {
        let fetchRequest = NSFetchRequest<Competition>(entityName: Competition.entityName())
        fetchRequest.predicate = NSPredicate(format: "parent.objectId = %d AND compType >= 0", self.dataController.currentCompetitionId())
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "compType", ascending: true)]
        do {
            self.childrenComptetitions = try self.dataController.mainContext.fetch(fetchRequest)
            
            if self.childrenComptetitions.count == 0 {
                self.emptyLabel.text = NSLocalizedString("No round tournaments", comment: "")
                return
            } else if self.childrenComptetitions.count == 1 {
                self.stageSelectorView.removeFromSuperview()
            }
            
            self.selectedCompetition = self.childrenComptetitions.first!
        } catch {}
    }
    
    fileprivate func getRoundRobin(_ showIndicator: Bool) {
        if let compId = self.selectedCompetition.objectId?.intValue {
            if (showIndicator) {
                self.activityView.startAnimating()
                self.roundTableView.isHidden = true
                self.playoffTableView.isHidden = true
                self.emptyLabel.isHidden = true
            }
            
            self.dataController.getRoundRobin(compId) { [weak self] error in
                if let strongSelf = self {
                    strongSelf.roundTableView.layoutIfNeeded()
                    strongSelf.refreshControlRound.endRefreshing()
                    
                    strongSelf.activityView.stopAnimating()
                    strongSelf.prevButton.isEnabled = true
                    strongSelf.nextButton.isEnabled = true
                    
                    if let _ = error {
                        strongSelf.emptyLabel.text = error?.localizedDescription
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                            strongSelf.emptyLabel.isHidden = false
                            strongSelf.roundTableView.isHidden = true
                        }
                        
                        let refreshButton = UIButton(type: .custom)
                        let attrString = NSAttributedString(string: NSLocalizedString("Refresh", comment: ""), attributes: [NSUnderlineStyleAttributeName : 1, NSForegroundColorAttributeName : UIColor.mlblLightOrangeColor()])
                        refreshButton.setAttributedTitle(attrString, for: UIControlState())
                        refreshButton.addTarget(self, action: #selector(strongSelf.refreshRoundRobin), for: .touchUpInside)
                        strongSelf.view.addSubview(refreshButton)
                        
                        refreshButton.snp.makeConstraints( { (make) in
                            make.centerX.equalTo(0)
                            make.top.equalTo(strongSelf.emptyLabel.snp.bottom)
                        })
                        
                        strongSelf.refreshButtonRound = refreshButton
                    } else {
                        strongSelf.roundTableView.reloadData()
                        strongSelf.roundTableView.isHidden = false
                        strongSelf.emptyLabel.isHidden = strongSelf.roundTableView.numberOfRows(inSection: 0) > 0
                        strongSelf.emptyLabel.text = NSLocalizedString("No team ranks stub", comment: "")
                    }
                }
            }
        }
    }
    
    fileprivate func getPlayoff(_ showIndicator: Bool) {
        if let compId = self.selectedCompetition.objectId?.intValue {
            if showIndicator {
                self.activityView.startAnimating()
                self.roundTableView.isHidden = true
                self.playoffTableView.isHidden = true
                self.emptyLabel.isHidden = true
            }
            
            self.dataController.getPlayoff(compId) { [weak self] error in
                if let strongSelf = self {
                    strongSelf.playoffTableView.layoutIfNeeded()
                    strongSelf.refreshControlPlayoff.endRefreshing()
                    
                    strongSelf.activityView.stopAnimating()
                    strongSelf.prevButton.isEnabled = true
                    strongSelf.nextButton.isEnabled = true
                    
                    if let _ = error {
                        strongSelf.emptyLabel.text = error?.localizedDescription
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                            strongSelf.emptyLabel.isHidden = false
                            strongSelf.playoffTableView.isHidden = true
                        }
                        
                        let refreshButton = UIButton(type: .custom)
                        let attrString = NSAttributedString(string: NSLocalizedString("Refresh", comment: ""), attributes: [NSUnderlineStyleAttributeName : 1, NSForegroundColorAttributeName : UIColor.mlblLightOrangeColor()])
                        refreshButton.setAttributedTitle(attrString, for: UIControlState())
                        refreshButton.addTarget(self, action: #selector(strongSelf.refreshPlayoff), for: .touchUpInside)
                        strongSelf.view.addSubview(refreshButton)
                        
                        refreshButton.snp.makeConstraints({ (make) in
                            make.centerX.equalTo(0)
                            make.top.equalTo(strongSelf.emptyLabel.snp.bottom)
                        })
                        
                        strongSelf.refreshButtonPlayoff = refreshButton
                    } else {
                        strongSelf.playoffTableView.reloadData()
                        strongSelf.playoffTableView.isHidden = false
                        strongSelf.emptyLabel.isHidden = strongSelf.playoffTableView.numberOfRows(inSection: 0) > 0
                        strongSelf.emptyLabel.text = NSLocalizedString("No playoffs stub", comment: "")
                    }
                }
            }
        }
    }
    
    @objc fileprivate func refreshRoundRobin(_ sender: UIButton) {
        self.refreshButtonRound?.removeFromSuperview()
        self.refreshButtonRound = nil
        self.getRoundRobin(true)
    }
    
    @objc fileprivate func refreshPlayoff(_ sender: UIButton) {
        self.refreshButtonPlayoff?.removeFromSuperview()
        self.refreshButtonPlayoff = nil
        self.getPlayoff(true)
    }
    
    fileprivate func configureCell(_ cell: RobinTeamCell, atIndexPath indexPath: IndexPath) {
        cell.language = self.dataController.language
        cell.rank = self.fetchedResultsController.object(at: indexPath)
    }
    
    fileprivate func configureCell(_ cell: PlayoffCell, atIndexPath indexPath: IndexPath) {
        cell.language = self.dataController.language
        cell.playoffSerie = self.playoffFetchedResultsController.object(at: indexPath)
    }
    
    @IBAction fileprivate func prevDidTap() {
        if let index = self.childrenComptetitions.index(of: self.selectedCompetition) {
            self.prevButton.isEnabled = false
            self.nextButton.isEnabled = false
            
            if index > 0 {
                self.selectedCompetition = self.childrenComptetitions[index-1]
            } else {
                self.selectedCompetition = self.childrenComptetitions.last!
            }
        }
    }
    
    @IBAction fileprivate func nextDidTap() {
        if let index = self.childrenComptetitions.index(of: self.selectedCompetition) {
            self.prevButton.isEnabled = false
            self.nextButton.isEnabled = false
            
            if index < self.childrenComptetitions.count - 1 {
                self.selectedCompetition = self.childrenComptetitions[index+1]
            } else {
                self.selectedCompetition = self.childrenComptetitions.first!
            }
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGame" {
            let gameController = segue.destination as! GameController
            gameController.dataController = self.dataController
            gameController.gameId = self.selectedGameId!
        } else if segue.identifier == "goToGamesSerie" {
            let gameController = segue.destination as! PlayoffGamesController
            gameController.dataController = self.dataController
            gameController.gamesIds = self.selectedGameIds!
        } else if segue.identifier == "goToTeam" {
            let teamController = segue.destination as! TeamController
            teamController.dataController = self.dataController
            teamController.teamId = self.selectedTeamId!;
        }
    }
}

extension TableController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var res = 0
        
        if tableView == self.roundTableView {
            res = self.fetchedResultsController.sections?.count ?? 0
        } else {
            res = self.playoffFetchedResultsController.sections?.count ?? 0
        }
        return res
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var res = 0
        var sections: [NSFetchedResultsSectionInfo]?
        
        if tableView == self.roundTableView {
            sections = self.fetchedResultsController.sections
        } else {
            sections = self.playoffFetchedResultsController.sections
        }
        
        if let _ = sections {
            let currentSection = sections![section]
            res = currentSection.numberOfObjects
        }
        
        self.emptyLabel.isHidden = res > 0 ||
            tableView.isHidden
        
        return res
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.roundTableView {
            return self.rowHeight
        } else {
            return self.playoffRowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var res: CGFloat = 0
        
        if tableView == self.playoffTableView {
            // Только для игр на вылет
            res = 30
        }
        
        return res
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var res: String?
        
        if tableView == self.playoffTableView {
            // Только для игр на вылет
            let sectionInfo = self.playoffFetchedResultsController.sections?[section]
            if let playoffSerie = sectionInfo?.objects?.first as? PlayoffSerie {
                let isLanguageRu = self.dataController.language.contains("ru")
                res = isLanguageRu ? playoffSerie.roundNameRu : playoffSerie.roundNameEn
            }
        }
        
        return res
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var res: UIView?
        
        if tableView == self.playoffTableView {
            // Только для игр на вылет
            let label = UILabel()
            if #available(iOS 8.2, *) {
                label.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
            } else {
                label.font = UIFont.systemFont(ofSize: 15)
            }
            label.textAlignment = .center
            label.text = self.tableView(tableView, titleForHeaderInSection: section)
            label.textColor = UIColor.black
            res = label
        }
        return res
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if tableView == self.roundTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "robinTeamCell", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "playoffCell", for: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        if tableView == self.roundTableView {
            self.configureCell(cell as! RobinTeamCell, atIndexPath:indexPath)
        } else {
            self.configureCell(cell as! PlayoffCell, atIndexPath:indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == self.roundTableView {
            self.selectedTeamId = self.fetchedResultsController.object(at: indexPath).team?.objectId?.intValue
            if let _ = self.selectedTeamId {
                self.performSegue(withIdentifier: "goToTeam", sender: nil)
            }
        } else if tableView == self.playoffTableView {
            let playoffSerie = self.playoffFetchedResultsController.object(at: indexPath)
            if playoffSerie.games?.count == 1 {
                self.selectedGameId = (playoffSerie.games?.anyObject() as? Game)?.objectId?.intValue
                if let _ = self.selectedGameId {
                    self.performSegue(withIdentifier: "goToGame", sender: nil)
                }
            } else {
                self.selectedGameIds = (playoffSerie.games?.value(forKey: "objectId") as? NSSet)?.allObjects as? [Int]
                if self.selectedGameIds?.count ?? 0 > 0 {
                    self.performSegue(withIdentifier: "goToGamesSerie", sender: nil)
                }
            }
        }
    }
}

extension TableController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ frc: NSFetchedResultsController<NSFetchRequestResult>) {
        var tableView: UITableView
        if self.selectedCompetition.compType == 0 {
            tableView = self.roundTableView
        } else {
            tableView = self.playoffTableView
        }
        
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        var tableView: UITableView
        if self.selectedCompetition.compType == 0 {
            tableView = self.roundTableView
        } else {
            tableView = self.playoffTableView
        }
        
        switch type {
        case .move:
            tableView.deleteRows(at: [indexPath!], with:.fade)
            tableView.insertRows(at: [newIndexPath!], with:.fade)
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with:.fade)
            
        case .delete:
            tableView.deleteRows(at: [indexPath!], with:.fade)
            
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        var tableView: UITableView
        if self.selectedCompetition.compType == 0 {
            tableView = self.roundTableView
        } else {
            tableView = self.playoffTableView
        }
        
        switch(type) {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with:.fade)
            
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with:.fade)
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        var tableView: UITableView
        if self.selectedCompetition.compType == 0 {
            tableView = self.roundTableView
        } else {
            tableView = self.playoffTableView
        }
        
        tableView.endUpdates()
    }
}
