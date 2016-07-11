//
//  TournamentsRequest.swift
//  mlbl
//
//  Created by Valentin Shamardin on 07.07.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class TournamentsRequest: NetworkRequest {
    private let mlblTournamentId = 9001
    
    override func start() {
        if cancelled {
            finished = true
            return
        }
        
        guard let url = NSURL(string: "CompIssue/\(self.mlblTournamentId)", relativeToURL: self.baseUrl) else { fatalError("Failed to build URL") }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        if let _ = self.params {
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(self.params!, options: NSJSONWritingOptions.init(rawValue: 0))
            } catch {
                finished = true
                return
            }
        }
        
        self.sessionTask = localURLSession.dataTaskWithRequest(request)
        self.sessionTask?.resume()
    }
    
    override func processData() {
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(incomingData, options: .AllowFragments)
            if let dict = json as? [String:AnyObject] {
                self.error = NSError(domain: "internal app error", code: -1, userInfo: [NSLocalizedDescriptionKey : "Обработка запроса не реализована"])
            }
        } catch {
            self.error = NSError(domain: "json error", code: -1, userInfo: [NSLocalizedDescriptionKey : "Не смог разобрать json"])
        }
    }
}