//
//  SendTokenRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 19.12.2017.
//  Copyright © 2017 Valentin Shamardin. All rights reserved.
//

class SendTokenRequest: NetworkRequest {
    init(token: String, oldToken: String?, compId: Int) {
        super.init()
        
        self.params = ["token" : token,
                       "oldToken" : oldToken ?? token,
                       "appId" : 2,
                       "compId" : compId,
                       "compApi" : "reg.infobasket.ru"]
    }
    
    override func start() {
        super.start()
        
        if isCancelled {
            isFinished = true
            return
        }
        
        guard let url = URL(string: "https://russiabasket.ru/api/v1.0/register-device", relativeTo: nil) else { fatalError("Failed to build URL") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
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
                    if !success.boolValue {
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
}
