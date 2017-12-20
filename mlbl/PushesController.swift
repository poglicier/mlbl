//
//  PushesController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 19.12.2017.
//  Copyright © 2017 Valentin Shamardin. All rights reserved.
//

import UserNotifications

class PushesController {
    // MARK: - Public
    func registerForRemoteNotifications(_ application: UIApplication) {
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        } else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        } else if #available(iOS 8, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
    }
    
    func handlePushWith(userInfo: [AnyHashable:Any]) {
        print(userInfo.map { $0.key })
    }
}
