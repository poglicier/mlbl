//
//  StatisticsController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 18.07.16.
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


class StatisticsController: BaseController {

    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var emptyLabel: UILabel!
    @IBOutlet fileprivate var parameterLabelBackground: UIView!
    @IBOutlet fileprivate var filtersCollectionView: UICollectionView!
    @IBOutlet fileprivate var parameterLabel: UILabel!
    @IBOutlet fileprivate var parameterButton: UIButton!
    @IBOutlet fileprivate var parameterLabelTrailing: NSLayoutConstraint!
    fileprivate let rowHeight: CGFloat = 97
    fileprivate var parameters: [StatParameter]! = []
    fileprivate var selectedParameterId = 1
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate var refreshButton: UIButton?
    fileprivate var selectedPlayerId: Int?

    lazy fileprivate var fetchedResultsController: NSFetchedResultsController<PlayerRank> = {
        let fetchRequest = NSFetchRequest<PlayerRank>(entityName: PlayerRank.entityName())
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
    
    lazy fileprivate var formatter: NumberFormatter = {
        let f = NumberFormatter()
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidChange(_:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil)

        // Чтобы filtersCollectionView при пропадании не было видно поверх statusBar
        self.view.clipsToBounds = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private
    
    @objc fileprivate func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getParametersAndPlayers(false)
    }
    
    fileprivate func setupTableView() {
        self.tableView.contentInset = UIEdgeInsetsMake(4, 0, 4, 0)
        self.tableView.scrollsToTop = true
        
        self.refreshControl.tintColor = UIColor.mlblLightOrangeColor()
        self.refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for:.valueChanged)
        self.tableView.addSubview(self.refreshControl)
        self.tableView.sendSubview(toBack: self.refreshControl)
    }
    
    fileprivate func setupFiltersCollectionView() {
        var newFrame = self.filtersCollectionView.frame
        newFrame.origin.y = -self.filtersCollectionView.frame.size.height
        self.filtersCollectionView.frame = newFrame
        self.filtersCollectionView.isHidden = true
        self.filtersCollectionView.scrollsToTop = false
        self.filtersCollectionView.allowsMultipleSelection = false
    }
    
    fileprivate func setupParameterLabel() {
        self.parameterLabel.text = nil
    }
    
    fileprivate func setupParameterButton() {
        self.parameterButton.setImage(UIImage(named: "filter")?.imageWithColor(UIColor.mlblDarkOrangeColor()), for: UIControlState())
        self.parameterButton.setImage(UIImage(named: "filter")?.imageWithColor(UIColor.mlblLightOrangeColor()), for: .highlighted)
    }
    
    fileprivate func setParamaterLabelText(_ text: String?) {
        if text != nil {
            let width = text!.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: self.parameterLabel.frame.size.height),
                                                 options: .usesLineFragmentOrigin,
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
    
    fileprivate func getParametersAndPlayers(_ showIndicator: Bool) {
        if showIndicator {
            self.activityView.startAnimating()
            self.tableView.isHidden = true
            self.emptyLabel.isHidden = true
            self.parameterLabelBackground.isHidden = true
        }
        
        var requestError: NSError?
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        self.dataController.getStatParameters({ error in
            requestError = error
            dispatchGroup.leave()
            })
        
        dispatchGroup.enter()
        self.dataController.getBestPlayers(self.selectedParameterId,
            completion: { (error, responseCount) in
                requestError = error
                dispatchGroup.leave()
        })
        
        dispatchGroup.notify(queue: DispatchQueue.main, execute: { [weak self] in
            if let strongSelf = self {
                strongSelf.activityView.stopAnimating()
                
                strongSelf.tableView.layoutIfNeeded()
                strongSelf.refreshControl.endRefreshing()
                
                if let _ = requestError {
                    strongSelf.emptyLabel.text = requestError?.localizedDescription
                    strongSelf.emptyLabel.isHidden = false
                    strongSelf.tableView.isHidden = true
                    strongSelf.parameterLabelBackground.isHidden = true
                    
                    let refreshButton = UIButton(type: .custom)
                    let attrString = NSAttributedString(string: NSLocalizedString("Refresh", comment: ""), attributes: [NSUnderlineStyleAttributeName : 1, NSForegroundColorAttributeName : UIColor.mlblLightOrangeColor()])
                    refreshButton.setAttributedTitle(attrString, for: UIControlState())
                    refreshButton.addTarget(self, action: #selector(strongSelf.refreshDidTap), for: .touchUpInside)
                    strongSelf.view.addSubview(refreshButton)
                    
                    refreshButton.snp.makeConstraints({ (make) in
                        make.centerX.equalTo(0)
                        make.top.equalTo(strongSelf.emptyLabel.snp.bottom)
                    })
                    
                    strongSelf.refreshButton?.removeFromSuperview()
                    strongSelf.refreshButton = refreshButton
                    
                    strongSelf.parameterLabel.text = nil
                } else {
                    strongSelf.tableView.isHidden = false
                    strongSelf.emptyLabel.isHidden = strongSelf.tableView.numberOfRows(inSection: 0) > 0
                    strongSelf.emptyLabel.text = NSLocalizedString("No players stub", comment: "")
                    
                    let fetchRequest = NSFetchRequest<StatParameter>(entityName: StatParameter.entityName())
                    do {
                        strongSelf.parameters = try strongSelf.dataController.mainContext.fetch(fetchRequest).sorted { $0.objectId?.intValue ?? 0 < $1.objectId?.intValue ?? 0 }
                    } catch {}
                    strongSelf.filtersCollectionView.reloadData()
                    
                    // Это условие должно сработать только в первый раз
                    if strongSelf.parameterLabel.text == nil {
                        strongSelf.setParamaterLabelText(strongSelf.parameters.first?.name)
                    }
                    strongSelf.parameterLabelBackground.isHidden = false
                    
                    strongSelf.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "parameter.objectId = %d", strongSelf.selectedParameterId)
                    do {
                        try strongSelf.fetchedResultsController.performFetch()
                    } catch { }
                    strongSelf.tableView.reloadData()
                }
            }
            })
    }
    
    fileprivate func getPlayers(_ showIndicator: Bool) {
        var requestReady = false
        
        if showIndicator {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                if !requestReady {
                    self.activityView.startAnimating()
                }
            }
            self.tableView.isHidden = true
            self.emptyLabel.isHidden = true
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
                                                    strongSelf.emptyLabel.isHidden = false
                                                    strongSelf.tableView.isHidden = true
                                                    
                                                    let refreshButton = UIButton(type: .custom)
                                                    let attrString = NSAttributedString(string: NSLocalizedString("Refresh", comment: ""), attributes: [NSUnderlineStyleAttributeName : 1, NSForegroundColorAttributeName : UIColor.mlblLightOrangeColor()])
                                                    refreshButton.setAttributedTitle(attrString, for: .normal)
                                                    refreshButton.addTarget(self, action: #selector(strongSelf.refreshPlayersDidTap), for: .touchUpInside)
                                                    strongSelf.view.addSubview(refreshButton)
                                                    
                                                    refreshButton.snp.makeConstraints({ (make) in
                                                        make.centerX.equalTo(0)
                                                        make.top.equalTo(strongSelf.emptyLabel.snp.bottom)
                                                    })
                                                    
                                                    strongSelf.refreshButton?.removeFromSuperview()
                                                    strongSelf.refreshButton = refreshButton
                                                } else {
                                                    strongSelf.tableView.contentOffset = CGPoint.zero
                                                    
                                                    strongSelf.fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "parameter.objectId = %d", strongSelf.selectedParameterId)
                                                    do {
                                                        try strongSelf.fetchedResultsController.performFetch()
                                                    } catch { }
                                                    self?.tableView.reloadData()

                                                    strongSelf.tableView.isHidden = false
                                                    strongSelf.emptyLabel.isHidden = strongSelf.tableView.numberOfRows(inSection: 0) > 0
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
    
    @objc fileprivate func refreshDidTap(_ sender: UIButton) {
        self.refreshButton?.removeFromSuperview()
        self.refreshButton = nil
        self.getParametersAndPlayers(true)
    }
    
    @objc fileprivate func refreshPlayersDidTap(_ sender: UIButton) {
        self.refreshButton?.removeFromSuperview()
        self.refreshButton = nil
        self.getPlayers(true)
    }
    
    fileprivate func configureCell(_ cell: PlayerStatCell, atIndexPath indexPath: IndexPath) {
        cell.language = self.dataController.language
        cell.rank = self.fetchedResultsController.object(at: indexPath) 
    }
    
    @IBAction fileprivate func filtersDidTap() {
        if self.filtersCollectionView.isHidden {
            self.filtersCollectionView.isHidden = false
            var newFrame = self.filtersCollectionView.frame
            newFrame.origin.y = 44
            UIView.animate(withDuration: 0.3, animations: {
                self.filtersCollectionView.frame = newFrame
            }) 
            self.tableView.scrollsToTop = false
            self.filtersCollectionView.scrollsToTop = true
            
            self.emptyLabel.isHidden = true
        } else {
            var newFrame = self.filtersCollectionView.frame
            newFrame.origin.y = -self.filtersCollectionView.frame.size.height
            UIView.animate(withDuration: 0.3, animations: {
                self.filtersCollectionView.frame = newFrame
            }, completion: { (_) in
                self.filtersCollectionView.isHidden = true
            }) 
            self.tableView.scrollsToTop = true
            self.filtersCollectionView.scrollsToTop = false
        }
    }
    
    @objc fileprivate func contextDidChange(_ notification: Notification) {
        if (notification.object as? NSManagedObjectContext) == self.dataController.mainContext {
            let inserted = (notification as NSNotification).userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>
            let updated = (notification as NSNotification).userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>
            if (inserted?.filter{ $0 is StatParameter })?.count > 0 ||
                (updated?.filter{ $0 is StatParameter })?.count > 0 {
                let fetchRequest = NSFetchRequest<StatParameter>(entityName: StatParameter.entityName())
                do {
                    self.parameters = try self.dataController.mainContext.fetch(fetchRequest).sorted { $0.objectId?.intValue ?? 0 < $1.objectId?.intValue ?? 0 }
                } catch {}
                self.filtersCollectionView.reloadData()
            }
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPlayer" {
            let playerController = segue.destination as! PlayerController
            playerController.dataController = self.dataController
            playerController.playerId = self.selectedPlayerId!
        }
    }
}

extension StatisticsController: UITableViewDelegate, UITableViewDataSource {
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
        return self.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerStatCell", for: indexPath) as! PlayerStatCell
        cell.formatter = self.formatter
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        self.configureCell(cell as! PlayerStatCell, atIndexPath:indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.selectedPlayerId = self.fetchedResultsController.object(at: indexPath).player?.objectId as? Int
        
        if let _ = self.selectedPlayerId {
            self.performSegue(withIdentifier: "goToPlayer", sender: nil)
        }
    }
}

extension StatisticsController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.parameters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "parameterCell", for: indexPath) as! ParameterCell
        let parameter = self.parameters[(indexPath as NSIndexPath).row]
        cell.parameter = parameter
        cell.isParameterSelected = parameter.objectId?.intValue == self.selectedParameterId
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let parameterCell = collectionView.cellForItem(at: indexPath) as? ParameterCell {
            parameterCell.isParameterSelected = true
            let parameter = self.parameters[(indexPath as NSIndexPath).row]
            
            if parameter.objectId?.intValue != self.selectedParameterId {
                self.selectedParameterId = (parameter.objectId as? Int) ?? 1
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.35 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                    self.setParamaterLabelText(parameter.name)
                }
                
                self.getPlayers(true)
            }

            collectionView.reloadData()
            
            self.filtersDidTap()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let parameterCell = collectionView.cellForItem(at: indexPath) as? ParameterCell {
            parameterCell.isParameterSelected = false
        }
    }
}

extension StatisticsController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let name =  self.parameters[(indexPath as NSIndexPath).row].name {
            var size = name.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 44),
                                                 options: .usesLineFragmentOrigin,
                                                 attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17)],
                                                 context: nil).size
            size.width = min(size.width + 10, collectionView.frame.size.width - 2*8)
            size.height = 44
            return size
        } else {
            return CGSize.zero
        }
    }
}

extension StatisticsController: NSFetchedResultsControllerDelegate {
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
