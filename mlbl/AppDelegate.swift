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

    // MARK: - Private
    
    fileprivate var pushesController: PushesController!
    fileprivate var dataController: DataController!
    
    // MARK: - UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self()])
        
        self.dataController = DataController()
        self.pushesController = PushesController()
        
        let rootNavigationController = self.window?.rootViewController as! UINavigationController
        var firstController: BaseController = rootNavigationController.viewControllers.first as! BaseController

        let fetchRequest = NSFetchRequest<Competition>(entityName: Competition.entityName())
        fetchRequest.predicate = NSPredicate(format: "isChoosen = true")
        do {
            if let _ = try self.dataController.mainContext.fetch(fetchRequest).first {
                firstController = self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "mainController") as! BaseController
                rootNavigationController.viewControllers = [firstController]
            }
        } catch {}
        
        firstController.dataController = self.dataController
        (firstController as? ChooseCompetitionController)?.pushesController = self.pushesController
        (firstController as? MainController)?.pushesController = self.pushesController
        
        if let userInfo = launchOptions?[.remoteNotification] as? [AnyHashable:Any] {
            self.pushesController.handlePushWith(userInfo: userInfo)
        }
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        DefaultsController.shared.save()
        self.dataController.terminateRequests()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        DefaultsController.shared.save()
    }
    
    // MARK: - APNS
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("APNS TOKEN", token)
        
        let oldToken = DefaultsController.shared.apnsToken
        
        if token != oldToken {
            self.dataController.sendAPNSToken(token, oldToken: oldToken) { (error) in
                if error == nil {
                    DefaultsController.shared.apnsToken = token
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register:", error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        self.pushesController.handlePushWith(userInfo: userInfo)
    }
}
