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
        case Teams
        case Players
        case Schedule
        case Ratings
        
        var description: String {
            switch self {
            case .Games:
                return "Games"
            case .Teams:
                return "Teams"
            case .Players:
                return "Players"
            case .Schedule:
                return "Schedule"
            case .Ratings:
                return "Ratings"
            }
        }
    }
    
    private var currentControllerType = ControllerType.Games
    private var activeController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.performSegueWithIdentifier(self.currentControllerType.description, sender: nil)
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let identifier = segue.identifier {
//            if let segueId = SegueId(rawValue: identifier) {
//                switch segueId {
//                case .Games:
                    if self.childViewControllers.count > 0 {
                        self.swapFromViewController(self.activeController!, toViewController:segue.destinationViewController)
                    }
                    else {
                        self.addChildViewController(segue.destinationViewController)
                        segue.destinationViewController.view.frame = self.view.bounds
                        self.view.addSubview(segue.destinationViewController.view)
                        segue.destinationViewController.didMoveToParentViewController(self)
                    }
        self.activeController = segue.destinationViewController
//                case .Teams:
//                    break
//                case .Players:
//                    break
//                case .Schedule:
//                    break
//                case .Ratings:
//                    break
//                }
//            }
//        }
    }
    
    private func swapFromViewController(fromViewController: UIViewController, toViewController:UIViewController) {
        toViewController.view.frame = self.view.bounds

        fromViewController.willMoveToParentViewController(nil)
        self.addChildViewController(toViewController)
        self.transitionFromViewController(fromViewController,
            toViewController: toViewController,
            duration: 0.3,
            options: .TransitionCrossDissolve,
            animations: nil) { (_) -> Void in
                fromViewController.removeFromParentViewController()
                toViewController.didMoveToParentViewController(self)
        }
    }

    // MARK: - Public
    
    func goToControllerWithControllerType(type: ControllerType) {
        self.currentControllerType = type
        self.performSegueWithIdentifier(self.currentControllerType.description, sender:nil)
    }
}
