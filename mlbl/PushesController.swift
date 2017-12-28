//
//  PushesController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 19.12.2017.
//  Copyright © 2017 Valentin Shamardin. All rights reserved.
//

import UserNotifications

class PushesController {
    // MARK: - Private
    
    fileprivate var dataController: DataController!
    
    // MARK: - Public
    
    func registerForRemoteNotifications(_ application: UIApplication) {
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        } else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
    }
    
    func handlePushWith(userInfo: [AnyHashable:Any]) {
        let showAlert = (userInfo["showAlert"] as? NSNumber)?.boolValue ?? false
        
        if UIApplication.shared.applicationState == .active &&
            showAlert {
            print("RETURN")
            return
        }
        
        if let action = userInfo["action"] as? String {
            if let entityIdStr = userInfo["entityId"] as? String {
                let entityId = entityIdStr.integer()
                
                var baseController: BaseController?
                switch action {
                case "openGame":
                    baseController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameController") as! GameController
                    (baseController as! GameController).gameId = entityId
                case "openTeam":
                    baseController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TeamController") as! TeamController
                    (baseController as! TeamController).teamId = entityId
                case "openPlayer":
                    baseController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayerController") as! PlayerController
                    (baseController as! PlayerController).playerId = entityId
                default:
                    break
                }
                
                if let _ = baseController {
                    let navigationController = UIApplication.shared.delegate?.window??.rootViewController as? UINavigationController
                    if let top = navigationController?.topViewController as? BaseController {
                        baseController!.dataController = top.dataController
                        baseController!.pushesController = top.pushesController
                        navigationController?.pushViewController(baseController!, animated: true)
                    }
                }
            }
        }
    }
}
