//
//  GameController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 07.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import CoreData

class GameController: BaseController {
    private enum Sections: NSInteger {
        case Hat
        case TeamA
        case TeamB
        case Count
    }
    
    var gameId: Int!
    private var game: Game?
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false
        self.setupTableView()
        
        self.getData()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(contextDidChange(_:)), name: NSManagedObjectContextObjectsDidChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Private 
    
    private func setupTableView() {
        self.tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
    }
    
    private func getData() {
        self.activityView.hidden = false
        self.activityView.startAnimating()
        
        self.dataController.getGameStats(self.gameId) { [weak self] (error) in
                if let strongSelf = self {
                    strongSelf.activityView.hidden = true
                    
                    if let _ = error {
                        let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error!.userInfo[NSLocalizedDescriptionKey] as? String, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
                        
                        self?.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        let fetchRequest = NSFetchRequest(entityName: Game.entityName())
                        fetchRequest.predicate = NSPredicate(format: "objectId = \(strongSelf.gameId)")
                        do {
                            strongSelf.game = try strongSelf.dataController.mainContext.executeFetchRequest(fetchRequest).first as? Game
                        } catch {}
                        strongSelf.tableView.reloadData()
                    }
                }
            }
    }
    
    private func configureCell(cell: GameScoreCell, atIndexPath indexPath: NSIndexPath) {
        cell.language = self.dataController.language
        cell.game = self.game
    }
    
    private func configureCell(cell: GameStatsCell, atIndexPath indexPath: NSIndexPath) {
        cell.language = self.dataController.language
        cell.teamNumber = indexPath.section
        cell.game = self.game
    }
    
    @objc private func contextDidChange(notification: NSNotification) {
        if (notification.object as? NSManagedObjectContext) == self.dataController.mainContext {
            let inserted = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>
            let updated = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>
            if (inserted?.filter{ $0 is GameStatistics })?.count > 0 ||
                (updated?.filter{ $0 is GameStatistics })?.count > 0 {
                let fetchRequest = NSFetchRequest(entityName: Game.entityName())
                fetchRequest.predicate = NSPredicate(format: "objectId = \(self.gameId)")
                do {
                    self.game = try self.dataController.mainContext.executeFetchRequest(fetchRequest).first as? Game
                } catch {}
                self.tableView.reloadData()
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

extension GameController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Sections.Count.rawValue
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var res = 0
        
        if self.game == nil {
            res = 0
        } else {
            if let gameSection = Sections(rawValue: section) {
                switch gameSection {
                case .Hat:
                    res = 1
                case .TeamA:
                    res = 1
                case .TeamB:
                    res = 1
                default:
                    res = 0
                }
            }
        }
        
        return res
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var res: CGFloat = 150
        
        if indexPath.section == Sections.Hat.rawValue {
            res = 252
        } else {
            if let statistics = ((self.game?.statistics as? Set<GameStatistics>)?.filter {$0.teamNumber?.integerValue == indexPath.section && $0.player != nil }) {
                res += CGFloat((statistics.count)*27)
            }
        }
        
        return res
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let gameSection = Sections(rawValue: indexPath.section) {
            switch gameSection {
            case .Hat:
                let cellIdentifier = "gameScoreCell"
                cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
            default:
                let cellIdentifier = "gameStatsCell"
                cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
            }
        } else {
            cell = UITableViewCell()
        }
        
        return cell
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let gameSection = Sections(rawValue: indexPath.section) {
            switch gameSection {
            case .Hat:
                self.configureCell(cell as! GameScoreCell, atIndexPath:indexPath)
            default:
                self.configureCell(cell as! GameStatsCell, atIndexPath:indexPath)
            }
        }
    }
}