//
//  StatisticsController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 18.07.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import CoreData

class StatisticsController: BaseController {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var emptyLabel: UILabel!
    @IBOutlet private var parameterLabelBackground: UIView!
    @IBOutlet private var filtersCollectionView: UICollectionView!
    @IBOutlet private var parameterLabel: UILabel!
    @IBOutlet private var parameterButton: UIButton!
    @IBOutlet private var parameterLabelTrailing: NSLayoutConstraint!
    private let rowHeight: CGFloat = 97
    private var parameters: [StatParameter]! = []
    private var selectedParameterId = 1
    private let refreshControl = UIRefreshControl()
    private var refreshButton: UIButton?
    private var selectedPlayerId: Int?

    lazy private var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: PlayerRank.entityName())
        fetchRequest.predicate = NSPredicate(format: "parameter.objectId = %d", self.selectedParameterId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "res", ascending: false)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.dataController.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        frc.delegate = self
        
        return frc
    }()
    
    lazy private var formatter: NSNumberFormatter = {
        let f = NSNumberFormatter()
        f.maximumFractionDigits = 1
        return f
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getParametersAndPlayers(true)
        self.setupTableView()
        self.setupFiltersCollectionView()
        self.setupParameterLabel()
        self.setupParameterButton()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(contextDidChange(_:)), name: NSManagedObjectContextObjectsDidChangeNotification, object: nil)

        // Чтобы filtersCollectionView при пропадании не было видно поверх statusBar
        self.view.clipsToBounds = true
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - Private
    
    @objc private func handleRefresh(refreshControl: UIRefreshControl) {
        self.getParametersAndPlayers(false)
    }
    
    private func setupTableView() {
        self.tableView.contentInset = UIEdgeInsetsMake(4, 0, 4, 0)
        self.tableView.scrollsToTop = true
        
        self.refreshControl.tintColor = UIColor.mlblLightOrangeColor()
        self.refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), forControlEvents:.ValueChanged)
        self.tableView.addSubview(self.refreshControl)
        self.tableView.sendSubviewToBack(self.refreshControl)
    }
    
    private func setupFiltersCollectionView() {
        var newFrame = self.filtersCollectionView.frame
        newFrame.origin.y = -self.filtersCollectionView.frame.size.height
        self.filtersCollectionView.frame = newFrame
        self.filtersCollectionView.hidden = true
        self.filtersCollectionView.scrollsToTop = false
        self.filtersCollectionView.allowsMultipleSelection = false
    }
    
    private func setupParameterLabel() {
        self.parameterLabel.text = nil
    }
    
    private func setupParameterButton() {
        self.parameterButton.setImage(UIImage(named: "filter")?.imageWithColor(UIColor.mlblDarkOrangeColor()), forState: .Normal)
        self.parameterButton.setImage(UIImage(named: "filter")?.imageWithColor(UIColor.mlblLightOrangeColor()), forState: .Highlighted)
    }
    
    private func setParamaterLabelText(text: String?) {
        if text != nil {
            let width = text!.boundingRectWithSize(CGSizeMake(CGFloat.max, self.parameterLabel.frame.size.height),
                                                 options: .UsesLineFragmentOrigin,
                                                 attributes: [NSFontAttributeName : self.parameterLabel.font],
                                                 context: nil).size.width
            if width > self.view.frame.size.width - 2*8 - 2*self.parameterButton.frame.size.width {
                self.parameterLabelTrailing.constant = self.parameterButton.frame.size.width + 8
            } else {
                self.parameterLabelTrailing.constant = 8
            }
        }
        
        self.parameterLabel.text = text
    }
    
    private func getParametersAndPlayers(showIndicator: Bool) {
        if showIndicator {
            self.activityView.startAnimating()
            self.tableView.hidden = true
            self.emptyLabel.hidden = true
            self.parameterLabelBackground.hidden = true
        }
        
        var requestError: NSError?
        
        let dispatchGroup = dispatch_group_create()
        dispatch_group_enter(dispatchGroup)
        self.dataController.getStatParameters({ error in
            requestError = error
            dispatch_group_leave(dispatchGroup)
            })
        
        dispatch_group_enter(dispatchGroup)
        self.dataController.getBestPlayers(self.selectedParameterId,
            completion: { (error, responseCount) in
                requestError = error
                dispatch_group_leave(dispatchGroup)
        })
        
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), { [weak self] in
            if let strongSelf = self {
                strongSelf.activityView.stopAnimating()
                
                strongSelf.tableView.layoutIfNeeded()
                strongSelf.refreshControl.endRefreshing()
                
                if let _ = requestError {
                    strongSelf.emptyLabel.text = requestError?.localizedDescription
                    strongSelf.emptyLabel.hidden = false
                    strongSelf.tableView.hidden = true
                    strongSelf.parameterLabelBackground.hidden = true
                    
                    let refreshButton = UIButton(type: .Custom)
                    let attrString = NSAttributedString(string: NSLocalizedString("Refresh", comment: ""), attributes: [NSUnderlineStyleAttributeName : 1, NSForegroundColorAttributeName : UIColor.mlblLightOrangeColor()])
                    refreshButton.setAttributedTitle(attrString, forState: .Normal)
                    refreshButton.addTarget(self, action: #selector(strongSelf.refreshDidTap), forControlEvents: .TouchUpInside)
                    strongSelf.view.addSubview(refreshButton)
                    
                    refreshButton.snp_makeConstraints(closure: { (make) in
                        make.centerX.equalTo(0)
                        make.top.equalTo(strongSelf.emptyLabel.snp_bottom)
                    })
                    
                    strongSelf.refreshButton?.removeFromSuperview()
                    strongSelf.refreshButton = refreshButton
                    
                    strongSelf.parameterLabel.text = nil
                } else {
                    strongSelf.tableView.hidden = false
                    strongSelf.emptyLabel.hidden = strongSelf.tableView.numberOfRowsInSection(0) > 0
                    strongSelf.emptyLabel.text = NSLocalizedString("No players stub", comment: "")
                    
                    let fetchRequest = NSFetchRequest(entityName: StatParameter.entityName())
                    do {
                        strongSelf.parameters = (try strongSelf.dataController.mainContext.executeFetchRequest(fetchRequest) as! [StatParameter]).sort { $0.objectId?.integerValue ?? 0 < $1.objectId?.integerValue ?? 0 }
                    } catch {}
                    strongSelf.filtersCollectionView.reloadData()
                    
                    strongSelf.setParamaterLabelText(strongSelf.parameters.first?.name)
                    strongSelf.parameterLabelBackground.hidden = false
                    
                    strongSelf.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "parameter.objectId = %d", strongSelf.selectedParameterId)
                    do {
                        try strongSelf.fetchedResultsController.performFetch()
                    } catch { }
                    strongSelf.tableView.reloadData()
                }
            }
            })
    }
    
    private func getPlayers(showIndicator: Bool) {
        var requestReady = false
        
        if showIndicator {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                if !requestReady {
                    self.activityView.startAnimating()
                }
            }
            self.tableView.hidden = true
            self.emptyLabel.hidden = true
        }
        
        self.dataController.getBestPlayers(self.selectedParameterId,
                                           completion: { [weak self] (error, responseCount) in
                                            requestReady = true
                                            if let strongSelf = self {
                                                strongSelf.activityView.stopAnimating()
                                                
                                                strongSelf.tableView.layoutIfNeeded()
                                                strongSelf.refreshControl.endRefreshing()
                                                
                                                if let _ = error {
                                                    strongSelf.emptyLabel.text = error?.localizedDescription
                                                    strongSelf.emptyLabel.hidden = false
                                                    strongSelf.tableView.hidden = true
                                                    
                                                    let refreshButton = UIButton(type: .Custom)
                                                    let attrString = NSAttributedString(string: NSLocalizedString("Refresh", comment: ""), attributes: [NSUnderlineStyleAttributeName : 1, NSForegroundColorAttributeName : UIColor.mlblLightOrangeColor()])
                                                    refreshButton.setAttributedTitle(attrString, forState: .Normal)
                                                    refreshButton.addTarget(self, action: #selector(strongSelf.refreshPlayersDidTap), forControlEvents: .TouchUpInside)
                                                    strongSelf.view.addSubview(refreshButton)
                                                    
                                                    refreshButton.snp_makeConstraints(closure: { (make) in
                                                        make.centerX.equalTo(0)
                                                        make.top.equalTo(strongSelf.emptyLabel.snp_bottom)
                                                    })
                                                    
                                                    strongSelf.refreshButton?.removeFromSuperview()
                                                    strongSelf.refreshButton = refreshButton
                                                } else {
                                                    strongSelf.tableView.contentOffset = CGPointZero
                                                    
                                                    strongSelf.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "parameter.objectId = %d", strongSelf.selectedParameterId)
                                                    do {
                                                        try strongSelf.fetchedResultsController.performFetch()
                                                    } catch { }
                                                    self?.tableView.reloadData()

                                                    strongSelf.tableView.hidden = false
                                                    strongSelf.emptyLabel.hidden = strongSelf.tableView.numberOfRowsInSection(0) > 0
                                                    strongSelf.emptyLabel.text = NSLocalizedString("No players stub", comment: "")
                                                }
                                            }
            })
    }
    
    override func willEnterForegroud() {
        if let _ = self.refreshButton {
            self.refreshButton?.removeFromSuperview()
            self.refreshButton = nil
            self.getParametersAndPlayers(true)
        } else {
            self.getParametersAndPlayers(false)
        }
    }
    
    @objc private func refreshDidTap(sender: UIButton) {
        self.refreshButton?.removeFromSuperview()
        self.refreshButton = nil
        self.getParametersAndPlayers(true)
    }
    
    @objc private func refreshPlayersDidTap(sender: UIButton) {
        self.refreshButton?.removeFromSuperview()
        self.refreshButton = nil
        self.getPlayers(true)
    }
    
    private func configureCell(cell: PlayerStatCell, atIndexPath indexPath: NSIndexPath) {
        cell.language = self.dataController.language
        cell.rank = self.fetchedResultsController.objectAtIndexPath(indexPath) as! PlayerRank
    }
    
    @IBAction private func filtersDidTap() {
        if self.filtersCollectionView.hidden {
            self.filtersCollectionView.hidden = false
            var newFrame = self.filtersCollectionView.frame
            newFrame.origin.y = 44
            UIView.animateWithDuration(0.3) {
                self.filtersCollectionView.frame = newFrame
            }
            self.tableView.scrollsToTop = false
            self.filtersCollectionView.scrollsToTop = true
            
            self.emptyLabel.hidden = true
        } else {
            var newFrame = self.filtersCollectionView.frame
            newFrame.origin.y = -self.filtersCollectionView.frame.size.height
            UIView.animateWithDuration(0.3, animations: {
                self.filtersCollectionView.frame = newFrame
            }) { (_) in
                self.filtersCollectionView.hidden = true
            }
            self.tableView.scrollsToTop = true
            self.filtersCollectionView.scrollsToTop = false
        }
    }
    
    @objc private func contextDidChange(notification: NSNotification) {
        if (notification.object as? NSManagedObjectContext) == self.dataController.mainContext {
            let inserted = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>
            let updated = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>
            if (inserted?.filter{ $0 is StatParameter })?.count > 0 ||
                (updated?.filter{ $0 is StatParameter })?.count > 0 {
                let fetchRequest = NSFetchRequest(entityName: StatParameter.entityName())
                do {
                    self.parameters = (try self.dataController.mainContext.executeFetchRequest(fetchRequest) as! [StatParameter]).sort { $0.objectId?.integerValue ?? 0 < $1.objectId?.integerValue ?? 0 }
                } catch {}
                self.filtersCollectionView.reloadData()
            }
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToPlayer" {
            let playerController = segue.destinationViewController as! PlayerController
            playerController.dataController = self.dataController
            playerController.playerId = self.selectedPlayerId!
        }
    }
}

extension StatisticsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var res = 0
        
        if let sections = self.fetchedResultsController.sections {
            let currentSection = sections[section]
            res = currentSection.numberOfObjects
        }
        
        self.emptyLabel.hidden = res > 0 ||
            tableView.hidden
        
        return res
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("playerStatCell", forIndexPath: indexPath) as! PlayerStatCell
        cell.formatter = self.formatter
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
        
        self.configureCell(cell as! PlayerStatCell, atIndexPath:indexPath)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.selectedPlayerId = (self.fetchedResultsController.objectAtIndexPath(indexPath) as! PlayerRank).player?.objectId as? Int
        
        if let _ = self.selectedPlayerId {
            self.performSegueWithIdentifier("goToPlayer", sender: nil)
        }
    }
}

extension StatisticsController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.parameters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("parameterCell", forIndexPath: indexPath) as! ParameterCell
        let parameter = self.parameters[indexPath.row]
        cell.parameter = parameter
        cell.isParameterSelected = parameter.objectId == self.selectedParameterId
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let parameterCell = collectionView.cellForItemAtIndexPath(indexPath) as? ParameterCell {
            parameterCell.isParameterSelected = true
            let parameter = self.parameters[indexPath.row]
            
            if parameter.objectId != self.selectedParameterId {
                self.selectedParameterId = (parameter.objectId as? Int) ?? 1
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.35 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    self.setParamaterLabelText(parameter.name)
                }
                
                self.getPlayers(true)
            }

            collectionView.reloadData()
            
            self.filtersDidTap()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let parameterCell = collectionView.cellForItemAtIndexPath(indexPath) as? ParameterCell {
            parameterCell.isParameterSelected = false
        }
    }
}

extension StatisticsController : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let name =  self.parameters[indexPath.row].name {
            var size = name.boundingRectWithSize(CGSizeMake(CGFloat.max, 44),
                                                 options: .UsesLineFragmentOrigin,
                                                 attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17)],
                                                 context: nil).size
            size.width = min(size.width + 10, collectionView.frame.size.width - 2*8)
            size.height = 44
            return size
        } else {
            return CGSizeZero
        }
    }
}

extension StatisticsController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(frc: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation:.Fade)
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation:.Fade)
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation:.Fade)
            
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation:.Fade)
            
        case .Update:
            self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch(type) {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation:.Fade)
            
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation:.Fade)
            
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}