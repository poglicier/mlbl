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
        case games
        case table
        case players
        case statistics
        
        var description: String {
            switch self {
            case .games:
                return "Games"
            case .table:
                return "Table"
            case .players:
                return "Players"
            case .statistics:
                return "Statistics"
            }
        }
    }
    
    fileprivate var currentControllerType = ControllerType.games
    fileprivate var activeController: UIViewController?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.activeController == nil {
            self.performSegue(withIdentifier: self.currentControllerType.description, sender: nil)
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as? BaseController)?.dataController = self.dataController
        (segue.destination as? BaseController)?.pushesController = self.pushesController
        
        if self.children.count > 0 {
            segue.destination.view.frame = self.view.bounds
            self.activeController?.willMove(toParent: segue.destination)
            self.addChild(segue.destination)
            self.transition(from: self.activeController!,
                                              to: segue.destination,
                                              duration: 0.3,
                                              options: .transitionCrossDissolve,
                                              animations: nil) { (_) -> Void in
                                                segue.destination.didMove(toParent: self)
            }
        }
        else {
            self.addChild(segue.destination)
            segue.destination.view.frame = self.view.bounds
            self.view.addSubview(segue.destination.view)
            segue.destination.didMove(toParent: self)
        }
        
        self.activeController = segue.destination
    }

    // MARK: - Public
    
    func goToControllerWithControllerType(_ type: ControllerType) {
        if self.currentControllerType != type {
            self.currentControllerType = type
            
            var toViewController: UIViewController?
            
            switch type {
            case .games:
                toViewController = self.children.filter { $0 is GamesController }.first
            case .statistics:
                toViewController = self.children.filter { $0 is StatisticsController }.first
            case .players:
                toViewController = self.children.filter { $0 is PlayersController }.first
            case .table:
                toViewController = self.children.filter { $0 is TableController }.first
            }
            
            if let _ = toViewController {
                (toViewController as? BaseController)?.dataController = self.dataController
                (toViewController as? BaseController)?.pushesController = self.pushesController
                
                toViewController!.view.frame = self.view.bounds
                self.activeController?.willMove(toParent: toViewController)
                self.addChild(toViewController!)
                self.transition(from: self.activeController!,
                                                  to: toViewController!,
                                                  duration: 0.3,
                                                  options: .transitionCrossDissolve,
                                                  animations: nil) { (_) -> Void in
                                                    toViewController!.didMove(toParent: self)
                }
                
                self.activeController = toViewController
            } else {
                self.performSegue(withIdentifier: self.currentControllerType.description, sender:nil)
            }
        }
    }
}
