//
//  BaseController.swift
//  lementpro
//
//  Created by Valentin Shamardin on 05.02.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class BaseController: UIViewController {

//    var dataController: DataController!
    var tasks = [NSURLSessionTask]()
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        for task in tasks {
            task.cancel()
        }
        
        self.tasks.removeAll()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}