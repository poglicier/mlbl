//
//  Extensions.swift
//  mlbl
//
//  Created by Valentin Shamardin on 05.03.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit
import CoreData

extension NSManagedObject {
    static func entityName() -> String {
        return String(self)
    }
}

extension UIColor {
    static func mlblOrangeColor() -> UIColor {
        return UIColor(red: 252/255.0, green: 92/255.0, blue: 33/255.0, alpha: 1)
    }
}