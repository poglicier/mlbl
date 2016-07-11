//
//  NetworkRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 19.05.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class NetworkRequest: NSOperation {
    let baseUrl = NSURL(string: "http://reg.infobasket.ru/Widget/")
    var dataController: DataController?
    var sessionTask: NSURLSessionTask?
    let incomingData = NSMutableData()
    var error: NSError?
    var params: [String:AnyObject]?
    
    var localURLSession: NSURLSession {
        return NSURLSession(configuration: localConfig, delegate: self, delegateQueue: nil)
    }
    var localConfig: NSURLSessionConfiguration {
        return NSURLSessionConfiguration.defaultSessionConfiguration()
    }
    
    var internalFinished: Bool = false
    
    override var finished: Bool {
        get {
            return internalFinished
        }
        set {
            willChangeValueForKey("isFinished")
            internalFinished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
    override func  cancel() {
        super.cancel()
        self.sessionTask?.cancel()
    }
    
    // MARK: - Public
    
    func processData() {
        
    }
}

extension NetworkRequest: NSURLSessionDataDelegate {
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        if cancelled {
            finished = true
            sessionTask?.cancel()
            return
        }
        
        if let httpResponse = response as? NSHTTPURLResponse {
            if httpResponse.statusCode == 200 {
                
            }
        }
        
        completionHandler(.Allow)
    }

    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if cancelled {
            finished = true
            sessionTask?.cancel()
            return
        }
        incomingData.appendData(data)
    }
}

extension NetworkRequest: NSURLSessionTaskDelegate {
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if cancelled {
            finished = true
            sessionTask?.cancel()
            return
        }
        if error != nil {
            self.error = error
            print("Failed to receive response: \(error)")
            finished = true
            return
        }
        
        self.processData()
        
        finished = true
    }
}