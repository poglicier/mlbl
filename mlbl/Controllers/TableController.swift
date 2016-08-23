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
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var emptyLabel: UILabel!
    private let rowHeight: CGFloat = 112
    
    lazy private var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: Team.entityName())
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "nameRu", ascending: false)]
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.dataController.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
//        frc.delegate = self
        
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTableView()
        
        self.getSubCompetetions()
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {}
    }
    
    // MARK: - Private

    private func setupTableView() {
        self.tableView.contentInset = UIEdgeInsetsMake(4, 0, 4, 0)
        self.tableView.scrollsToTop = true
    }
    
    private func getSubCompetetions() {
        let fetchRequest = NSFetchRequest(entityName: Competition.entityName())
        fetchRequest.predicate = NSPredicate(format: "parent.objectId = %d", self.dataController.currentCompetitionId())
        do {
            let subCompetitions = try self.dataController.mainContext.executeFetchRequest(fetchRequest)
            print(subCompetitions)
        } catch {}
        
        self.getRoundRobin()
    }
    
    private func getRoundRobin() {
        self.activityView.startAnimating()
        self.tableView.hidden = true
        self.emptyLabel.hidden = true
        
        self.dataController.getRoundRobin() { [weak self] error in
            if let strongSelf = self {
                strongSelf.activityView.stopAnimating()
                
                if let _ = error {
                    strongSelf.emptyLabel.text = error?.localizedDescription
                    strongSelf.emptyLabel.hidden = false
                    
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
                    strongSelf.tableView.hidden = false
                    strongSelf.emptyLabel.hidden = strongSelf.tableView.numberOfRowsInSection(0) > 0
                    strongSelf.emptyLabel.text = NSLocalizedString("No games stub", comment: "")
                }
            }
        }
    }
    
    @objc private func refreshRoundRobin(sender: UIButton) {
        sender.removeFromSuperview()
        self.getRoundRobin()
    }
    
    private func configureCell(cell: RobinTeamCell, atIndexPath indexPath: NSIndexPath) {
        cell.language = self.dataController.language
//        cell.rank = self.fetchedResultsController.objectAtIndexPath(indexPath) as! PlayerRank
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
        let cell = tableView.dequeueReusableCellWithIdentifier("robinTeamCell", forIndexPath: indexPath) as! RobinTeamCell
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        self.configureCell(cell as! RobinTeamCell, atIndexPath:indexPath)
    }
}