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
        return 252
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let cellIdentifier = "gameScoreCell"
        cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        self.configureCell(cell as! GameScoreCell, atIndexPath:indexPath)
    }
}