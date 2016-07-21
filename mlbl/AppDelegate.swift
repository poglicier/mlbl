//
//  AppDelegate.swift
//  mlbl
//
//  Created by Valentin Shamardin on 26.02.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self()])
        
        let dataController = DataController()
        
        let rootNavigationController = self.window?.rootViewController as! UINavigationController
        var firstController: BaseController = rootNavigationController.viewControllers.first as! BaseController

        let fetchRequest = NSFetchRequest(entityName: Competition.entityName())
        fetchRequest.predicate = NSPredicate(format: "isChoosen = true")
        do {
            if let _ = try dataController.mainContext.executeFetchRequest(fetchRequest).first {
                firstController = self.window?.rootViewController?.storyboard?.instantiateViewControllerWithIdentifier("mainController") as! BaseController
                rootNavigationController.viewControllers = [firstController]
            }
        } catch {}
        
        firstController.dataController = dataController
        
        return true
    }
}