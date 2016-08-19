//
//  ContainerController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 27.02.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class ContainerController: BaseController {
    enum ControllerType: Int, CustomStringConvertible {
        case Games
        case Table
        case Players
        case Statistics
        
        var description: String {
            switch self {
            case .Games:
                return "Games"
            case .Table:
                return "Table"
            case .Players:
                return "Players"
            case .Statistics:
                return "Statistics"
            }
        }
    }
    
    private var currentControllerType = ControllerType.Games
    private var activeController: UIViewController?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if self.activeController == nil {
            self.performSegueWithIdentifier(self.currentControllerType.description, sender: nil)
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        (segue.destinationViewController as? BaseController)?.dataController = self.dataController
        
        if self.childViewControllers.count > 0 {
            segue.destinationViewController.view.frame = self.view.bounds
            self.activeController?.willMoveToParentViewController(segue.destinationViewController)
            self.addChildViewController(segue.destinationViewController)
            self.transitionFromViewController(self.activeController!,
                                              toViewController: segue.destinationViewController,
                                              duration: 0.3,
                                              options: .TransitionCrossDissolve,
                                              animations: nil) { (_) -> Void in
                                                segue.destinationViewController.didMoveToParentViewController(self)
            }
        }
        else {
            self.addChildViewController(segue.destinationViewController)
            segue.destinationViewController.view.frame = self.view.bounds
            self.view.addSubview(segue.destinationViewController.view)
            segue.destinationViewController.didMoveToParentViewController(self)
        }
        
        self.activeController = segue.destinationViewController
    }

    // MARK: - Public
    
    func goToControllerWithControllerType(type: ControllerType) {
        if self.currentControllerType != type {
            self.currentControllerType = type
            
            var toViewController: UIViewController?
            
            switch type {
            case .Games:
                toViewController = self.childViewControllers.filter { $0 is GamesController }.first
            case .Statistics:
                toViewController = self.childViewControllers.filter { $0 is StatisticsController }.first
            case .Players:
                toViewController = self.childViewControllers.filter { $0 is PlayersController }.first
            case .Table:
                toViewController = self.childViewControllers.filter { $0 is TableController }.first
            }
            
            if let _ = toViewController {
                (toViewController as? BaseController)?.dataController = self.dataController
                
                toViewController!.view.frame = self.view.bounds
                self.activeController?.willMoveToParentViewController(toViewController)
                self.addChildViewController(toViewController!)
                self.transitionFromViewController(self.activeController!,
                                                  toViewController: toViewController!,
                                                  duration: 0.3,
                                                  options: .TransitionCrossDissolve,
                                                  animations: nil) { (_) -> Void in
                                                    toViewController!.didMoveToParentViewController(self)
                }
                
                self.activeController = toViewController
            } else {
                self.performSegueWithIdentifier(self.currentControllerType.description, sender:nil)
            }
        }
    }
}
