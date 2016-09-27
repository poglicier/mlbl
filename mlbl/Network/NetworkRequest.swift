//
//  NetworkRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 19.05.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import CoreData

class NetworkRequest: Operation {
    let baseUrl = URL(string: "http://reg.infobasket.ru/Widget/")
    var dataController: DataController?
    var sessionTask: URLSessionTask?
    let incomingData = NSMutableData()
    var error: NSError?
    var params: [String:AnyObject]?
    
    var localURLSession: Foundation.URLSession {
        return Foundation.URLSession(configuration: localConfig, delegate: self, delegateQueue: nil)
    }
    var localConfig: URLSessionConfiguration {
        return URLSessionConfiguration.default
    }
    
    var internalFinished: Bool = false
    
    override var isFinished: Bool {
        get {
            return internalFinished
        }
        set {
            willChangeValue(forKey: "isFinished")
            internalFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override func cancel() {
        super.cancel()
        self.sessionTask?.cancel()
    }
    
    // MARK: - Public
    
    func processData() {
        
    }
}

extension NetworkRequest: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if isCancelled {
            isFinished = true
            sessionTask?.cancel()
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                
            }
        }
        
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if isCancelled {
            isFinished = true
            sessionTask?.cancel()
            return
        }
        incomingData.append(data)
    }
}

extension NetworkRequest: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if isCancelled {
            isFinished = true
            sessionTask?.cancel()
            return
        }
        if error != nil {
            self.error = error as NSError?
            print("Failed to receive response: \(error)")
            isFinished = true
            return
        }
        
        self.processData()
        
        isFinished = true
    }
}
