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
    @IBOutlet private var roundTableView: UITableView!
    @IBOutlet private var playoffTableView: UITableView!
    @IBOutlet private var emptyLabel: UILabel!
    @IBOutlet private var stageSelectorView: UIView!
    @IBOutlet private var stageLabel: UILabel!
    @IBOutlet private var nextButton: UIButton!
    @IBOutlet private var prevButton: UIButton!
    private let rowHeight: CGFloat = 112
    private let playoffRowHeight: CGFloat = 180
    private var childrenComptetitions = [Competition]()
    private var selectedCompetition: Competition! {
        didSet {
            let isLanguageRu = self.dataController.language.containsString("ru")
            self.stageLabel.text = isLanguageRu ? selectedCompetition.compShortNameRu : selectedCompetition.compShortNameEn
            
            if selectedCompetition.compType?.integerValue ?? -1 == 0 {
                self.getRoundRobin()
                
                self.roundTableView.scrollsToTop = true
                self.playoffTableView.scrollsToTop = false
                self.roundTableView.contentOffset = CGPointMake(0, -4)
                self.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "competition = %@", self.selectedCompetition)
                do {
                    try self.fetchedResultsController.performFetch()
                } catch {}
                self.roundTableView.reloadData()
            } else {
                self.getPlayoff()
                
                self.roundTableView.scrollsToTop = false
                self.playoffTableView.scrollsToTop = true
                self.playoffTableView.contentOffset = CGPointZero
                self.playoffFetchedResultsController.fetchRequest.predicate = NSPredicate(format: "competition = %@", self.selectedCompetition)
                do {
                    try self.playoffFetchedResultsController.performFetch()
                } catch {}
                self.playoffTableView.reloadData()
            }
        }
    }
    
    lazy private var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: TeamRoundRank.entityName())
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
    
    lazy private var playoffFetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: PlayoffSerie.entityName())
        fetchRequest.predicate = NSPredicate(format: "competition = %@", self.selectedCompetition)
        let isLanguageRu = self.dataController.language.containsString("ru")
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

    private func setupTableViews() {
        self.roundTableView.contentInset = UIEdgeInsetsMake(4, 0, 4, 0)
    }
    
    private func setupSubcompetitions() {
        let fetchRequest = NSFetchRequest(entityName: Competition.entityName())
        fetchRequest.predicate = NSPredicate(format: "parent.objectId = %d AND compType >= 0", self.dataController.currentCompetitionId())
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "compType", ascending: true)]
        do {
            self.childrenComptetitions = try self.dataController.mainContext.executeFetchRequest(fetchRequest) as! [Competition]
            
            if self.childrenComptetitions.count == 0 {
                self.emptyLabel.text = NSLocalizedString("No round tournaments", comment: "")
                return
            } else if self.childrenComptetitions.count == 1 {
                self.stageSelectorView.removeFromSuperview()
            }
            
            self.selectedCompetition = self.childrenComptetitions.first!
        } catch {}
    }
    
    private func getRoundRobin() {
        if let compId = self.selectedCompetition.objectId?.integerValue {
            self.activityView.startAnimating()
            self.roundTableView.hidden = true
            self.playoffTableView.hidden = true
            self.emptyLabel.hidden = true
            
            self.dataController.getRoundRobin(compId) { [weak self] error in
                if let strongSelf = self {
                    strongSelf.activityView.stopAnimating()
                    strongSelf.prevButton.enabled = true
                    strongSelf.nextButton.enabled = true
                    
                    if let _ = error {
                        strongSelf.emptyLabel.text = error?.localizedDescription
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                            strongSelf.emptyLabel.hidden = false
                        }
                        
                        let refreshButton = UIButton(type: .Custom)
                        let attrString = NSAttributedString(string: NSLocalizedString("Refresh", comment: ""), attributes: [NSUnderlineStyleAttributeName : 1, NSForegroundColorAttributeName : UIColor.mlblLightOrangeColor()])
                        refreshButton.setAttributedTitle(attrString, forState: .Normal)
                        refreshButton.addTarget(self, action: #selector(strongSelf.refreshRoundRobin), forControlEvents: .TouchUpInside)
                        strongSelf.view.addSubview(refreshButton)
                        
                        refreshButton.snp_makeConstraints(closure: { (make) in
                            make.centerX.equalTo(0)
                            make.top.equalTo(strongSelf.emptyLabel.snp_bottom)
                        })
                    } else {
                        strongSelf.roundTableView.reloadData()
                        strongSelf.roundTableView.hidden = false
                        strongSelf.emptyLabel.hidden = strongSelf.roundTableView.numberOfRowsInSection(0) > 0
                        strongSelf.emptyLabel.text = NSLocalizedString("No team ranks stub", comment: "")
                    }
                }
            }
        }
    }
    
    private func getPlayoff() {
        if let compId = self.selectedCompetition.objectId?.integerValue {
            self.activityView.startAnimating()
            self.roundTableView.hidden = true
            self.playoffTableView.hidden = true
            self.emptyLabel.hidden = true
            
            self.dataController.getPlayoff(compId) { [weak self] error in
                if let strongSelf = self {
                    strongSelf.activityView.stopAnimating()
                    strongSelf.prevButton.enabled = true
                    strongSelf.nextButton.enabled = true
                    
                    if let _ = error {
                        strongSelf.emptyLabel.text = error?.localizedDescription
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                            strongSelf.emptyLabel.hidden = false
                        }
                        
                        let refreshButton = UIButton(type: .Custom)
                        let attrString = NSAttributedString(string: NSLocalizedString("Refresh", comment: ""), attributes: [NSUnderlineStyleAttributeName : 1, NSForegroundColorAttributeName : UIColor.mlblLightOrangeColor()])
                        refreshButton.setAttributedTitle(attrString, forState: .Normal)
                        refreshButton.addTarget(self, action: #selector(strongSelf.refreshPlayoff), forControlEvents: .TouchUpInside)
                        strongSelf.view.addSubview(refreshButton)
                        
                        refreshButton.snp_makeConstraints(closure: { (make) in
                            make.centerX.equalTo(0)
                            make.top.equalTo(strongSelf.emptyLabel.snp_bottom)
                        })
                    } else {
                        strongSelf.playoffTableView.reloadData()
                        strongSelf.playoffTableView.hidden = false
                        strongSelf.emptyLabel.hidden = strongSelf.playoffTableView.numberOfRowsInSection(0) > 0
                        strongSelf.emptyLabel.text = NSLocalizedString("No playoffs stub", comment: "")
                    }
                }
            }
        }
    }
    
    @objc private func refreshRoundRobin(sender: UIButton) {
        sender.removeFromSuperview()
        self.getRoundRobin()
    }
    
    @objc private func refreshPlayoff(sender: UIButton) {
        sender.removeFromSuperview()
        self.getPlayoff()
    }
    
    private func configureCell(cell: RobinTeamCell, atIndexPath indexPath: NSIndexPath) {
        cell.language = self.dataController.language
        cell.rank = self.fetchedResultsController.objectAtIndexPath(indexPath) as! TeamRoundRank
    }
    
    private func configureCell(cell: PlayoffCell, atIndexPath indexPath: NSIndexPath) {
        cell.language = self.dataController.language
        cell.playoffSerie = self.playoffFetchedResultsController.objectAtIndexPath(indexPath) as! PlayoffSerie
    }
    
    @IBAction private func prevDidTap() {
        if let index = self.childrenComptetitions.indexOf(self.selectedCompetition) {
            self.prevButton.enabled = false
            self.nextButton.enabled = false
            
            if index > 0 {
                self.selectedCompetition = self.childrenComptetitions[index-1]
            } else {
                self.selectedCompetition = self.childrenComptetitions.last!
            }
        }
    }
    
    @IBAction private func nextDidTap() {
        if let index = self.childrenComptetitions.indexOf(self.selectedCompetition) {
            self.prevButton.enabled = false
            self.nextButton.enabled = false
            
            if index < self.childrenComptetitions.count - 1 {
                self.selectedCompetition = self.childrenComptetitions[index+1]
            } else {
                self.selectedCompetition = self.childrenComptetitions.first!
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension TableController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var frc: NSFetchedResultsController
        
        if tableView == self.roundTableView {
            frc = self.fetchedResultsController
        } else {
            frc = self.playoffFetchedResultsController
        }
        return frc.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var res = 0
        var frc: NSFetchedResultsController
        
        if tableView == self.roundTableView {
            frc = self.fetchedResultsController
        } else {
            frc = self.playoffFetchedResultsController
        }
        
        if let sections = frc.sections {
            let currentSection = sections[section]
            res = currentSection.numberOfObjects
        }
        
        self.emptyLabel.hidden = res > 0 ||
            tableView.hidden
        
        return res
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.roundTableView {
            return self.rowHeight
        } else {
            return self.playoffRowHeight
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var res: CGFloat = 0
        
        if tableView == self.playoffTableView {
            // Только для игр на вылет
            res = 30
        }
        
        return res
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var res: String?
        
        if tableView == self.playoffTableView {
            // Только для игр на вылет
            let sectionInfo = self.playoffFetchedResultsController.sections?[section]
            if let playoffSerie = sectionInfo?.objects?.first as? PlayoffSerie {
                let isLanguageRu = self.dataController.language.containsString("ru")
                res = isLanguageRu ? playoffSerie.roundNameRu : playoffSerie.roundNameEn
            }
        }
        
        return res
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var res: UIView?
        
        if tableView == self.playoffTableView {
            // Только для игр на вылет
            let label = UILabel()
            if #available(iOS 8.2, *) {
                label.font = UIFont.systemFontOfSize(15, weight: UIFontWeightMedium)
            } else {
                label.font = UIFont.systemFontOfSize(15)
            }
            label.textAlignment = .Center
            label.text = self.tableView(tableView, titleForHeaderInSection: section)
            label.textColor = UIColor.blackColor()
            res = label
        }
        return res
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if tableView == self.roundTableView {
            cell = tableView.dequeueReusableCellWithIdentifier("robinTeamCell", forIndexPath: indexPath)
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("playoffCell", forIndexPath: indexPath)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.roundTableView {
            self.configureCell(cell as! RobinTeamCell, atIndexPath:indexPath)
        } else {
            self.configureCell(cell as! PlayoffCell, atIndexPath:indexPath)
        }
    }
}

extension TableController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(frc: NSFetchedResultsController) {
        var tableView: UITableView
        if self.selectedCompetition.compType == 0 {
            tableView = self.roundTableView
        } else {
            tableView = self.playoffTableView
        }
        
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        var tableView: UITableView
        if self.selectedCompetition.compType == 0 {
            tableView = self.roundTableView
        } else {
            tableView = self.playoffTableView
        }
        
        switch type {
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation:.Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation:.Fade)
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation:.Fade)
            
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation:.Fade)
            
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        var tableView: UITableView
        if self.selectedCompetition.compType == 0 {
            tableView = self.roundTableView
        } else {
            tableView = self.playoffTableView
        }
        
        switch(type) {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation:.Fade)
            
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation:.Fade)
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_: NSFetchedResultsController) {
        var tableView: UITableView
        if self.selectedCompetition.compType == 0 {
            tableView = self.roundTableView
        } else {
            tableView = self.playoffTableView
        }
        
        tableView.endUpdates()
    }
}