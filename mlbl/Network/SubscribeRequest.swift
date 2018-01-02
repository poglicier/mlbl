//
//  SubscribeRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 29.12.2017.
//  Copyright © 2017 Valentin Shamardin. All rights reserved.
//

import CoreData

class SubscribeRequest: NetworkRequest {
    init(subscribe: Bool, token: String, teamId: Int) {
        super.init()
        
        self.teamId = teamId
        self.subscribe = subscribe
        self.params = ["deviceToken" : token,
                       "entityType" : 2,
                       "entityId" : teamId,
                       "apiUrl" : "reg.infobasket.ru"]
    }
    
    override func start() {
        super.start()
        
        if isCancelled {
            isFinished = true
            return
        }
        
        guard let url = URL(string: "https://russiabasket.ru/api/v1.0/\(self.subscribe ? "subscribe" : "unsubscribe")-device", relativeTo: nil) else { fatalError("Failed to build URL") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        request.setValue(appVersion, forHTTPHeaderField: "appVersion")
        request.setValue("ios", forHTTPHeaderField: "platform")
        request.setValue(ProcessInfo().operatingSystemVersionString, forHTTPHeaderField: "platformVersion")
        request.setValue(UIDevice.current.model, forHTTPHeaderField: "device")
        
        if let _ = self.params {
            request.httpBody = self.createHttpParameters(with: self.params!).data(using: String.Encoding.utf8)
        }
        
        self.sessionTask = localURLSession.dataTask(with: request)
        self.sessionTask?.resume()
    }
    
    override func processData() {
        do {
            let json = try JSONSerialization.jsonObject(with: incomingData as Data, options: .allowFragments)
            if let result = json as? [String:AnyObject] {
                if let success = result["success"] as? NSNumber {
                    if success.boolValue {
                        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                        context.parent = self.dataController?.mainContext
                        context.performAndWait {
                            Team.updateSubscriptionInfo(forTeamWithId: self.teamId,
                                                        subscribed: subscribe,
                                                        isRegisteredForRemoteNotifications: true,
                                                        in: context)
                            self.dataController?.saveContext(context)
                        }
                    } else {
                        self.error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("apns token sending failed", comment: "")])
                    }
                } else {
                    self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("internal server wrong json object error", comment: "")])
                }
            }
        } catch {
            self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "Не смог разобрать json"])
        }
    }
    
    // MARK: - Private
    fileprivate var teamId: Int!
    fileprivate var subscribe: Bool!
}
