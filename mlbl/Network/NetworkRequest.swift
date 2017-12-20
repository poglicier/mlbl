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
    var params: [String:Any]?
    
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
    
    @nonobjc func createHttpParameters(with parameters: [String:Any]) -> String {
        var body = ""
        for (key, value) in parameters {
            if body.count > 0 {
                body += "&"
            }
            
            if value is String {
                body += "\(self.urlEncodedUTF8String(key))=\(self.urlEncodedUTF8String(value as! String))"
            } else if value is Bool {
                let strValue = (value as! Bool) ? "true" : "false"
                body += "\(self.urlEncodedUTF8String(key))=\(strValue)"
            } else if value is NSNull {
                body += "\(self.urlEncodedUTF8String(key))="
            } else {
                body += "\(self.urlEncodedUTF8String(key))=\(value)"
            }
        }
        
        return body
    }
    
    @nonobjc func createHttpParameters(with parameters: String) -> String {
        return self.urlEncodedUTF8String(parameters)
    }
    
    // MARK: - Private
    
    fileprivate func urlEncodedUTF8String(_ source: String) -> String {
        return source.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
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
