//
//  SubscriptionInfoRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 29.12.2017.
//  Copyright © 2017 Valentin Shamardin. All rights reserved.
//

import CoreData

class SubscriptionInfoRequest: NetworkRequest {
    init(teamId: Int, token: String, isRegisteredForRemoteNotifications: Bool) {
        super.init()
        
        self.teamId = teamId
        self.token = token
        self.isRegisteredForRemoteNotifications = isRegisteredForRemoteNotifications
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        let urlString = "https://russiabasket.ru/api/v1.0/is-device-subscribed?deviceToken=\(self.token!)&entityType=2&entityId=\(self.teamId!)&apiUrl=reg.infobasket.ru"
        guard let url = URL(string: urlString, relativeTo: nil) else { fatalError("Failed to build URL") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let _ = self.params {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: self.params!, options: JSONSerialization.WritingOptions.init(rawValue: 0))
            } catch {
                isFinished = true
                return
            }
        }
        
        self.sessionTask = localURLSession.dataTask(with: request)
        self.sessionTask?.resume()
    }
    
    override func processData() {
        do {
            let json = try JSONSerialization.jsonObject(with: incomingData as Data, options: .allowFragments)
            if let resultDict = json as? [String:Any] {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                context.parent = self.dataController?.mainContext
                context.performAndWait({
                    Team.updateSubscriptionInfo(forTeamWithId: self.teamId,
                                                subscribed: (resultDict["subscribed"] as? Bool) ?? false,
                                                isRegisteredForRemoteNotifications: self.isRegisteredForRemoteNotifications,
                                                in: context)
                    self.dataController?.saveContext(context)
                })
            } else {
                self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "json не является массивом словарей"])
            }
        } catch {
            self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "Не смог разобрать json"])
        }
    }
    
    // MARK: - Private
    
    fileprivate var teamId: Int!
    fileprivate var token: String!
    fileprivate var isRegisteredForRemoteNotifications: Bool!
}
