//
//  DefaultsController.swift
//  mlbl
//
//  Created by Valentin Shamardin on 19.12.2017.
//  Copyright © 2017 Valentin Shamardin. All rights reserved.
//

class DefaultsController {
    // MARK: - Private
    fileprivate let apnsTokenKey = "mlbltoken"

    // MARK: - Public
    var apnsToken: String?
    static let shared: DefaultsController = DefaultsController()
    
    func initialize() {
        self.apnsToken = UserDefaults.standard.string(forKey: self.apnsTokenKey)
    }
    
    func save() {
        UserDefaults.standard.set(self.apnsToken, forKey: self.apnsTokenKey)
        UserDefaults.standard.synchronize()
    }
}
