//
//  GameController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 07.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class GameController: BaseController {
    private enum Sections: NSInteger {
        case Hat
        case TeamA
        case TeamB
        case Count
    }
    
    var gameId: NSNumber!
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        //        if let sections = self.fetchedResultsController.sections {
        //            let currentSection = sections[section]
        //            return currentSection.numberOfObjects
        //        }
        //
        //        return 0
        return 15
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
//        self.configureCell(cell as! GameCell, atIndexPath:indexPath)
    }
}