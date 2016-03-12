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
    static func mlblLightOrangeColor() -> UIColor {
        return UIColor(red: 252/255.0, green: 92/255.0, blue: 33/255.0, alpha: 1)
    }
    
    static func mlblDarkOrangeColor() -> UIColor {
        return UIColor(red: 183/255.0, green: 65/255.0, blue: 19/255.0, alpha: 1)
    }
}

extension UIImage {
    static func imageWithView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
    }
    
    static func imageForNavigationBar(portrait portrait: Bool) -> UIImage {
        if portrait == true {
            UIGraphicsBeginImageContext(CGSizeMake(1, 64))
            let context = UIGraphicsGetCurrentContext()

            let rect1 = CGRectMake(0, 0, 1, 20)
            let color1 = UIColor.mlblDarkOrangeColor()
            let rect2 = CGRectMake(0, 20, 1, 44)
            let color2 = UIColor.mlblLightOrangeColor()
            
            CGContextSetFillColorWithColor(context, color1.CGColor)
            CGContextFillRect(context, rect1)
            CGContextSetFillColorWithColor(context, color2.CGColor)
            CGContextFillRect(context, rect2)
        } else {
            let rect2 = CGRectMake(0, 0, 1, 44)
            UIGraphicsBeginImageContext(rect2.size)
            
            let context = UIGraphicsGetCurrentContext()
            let color2 = UIColor.mlblLightOrangeColor()
            
            CGContextSetFillColorWithColor(context, color2.CGColor)
            CGContextFillRect(context, rect2)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension UINavigationController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        self.navigationBar.setBackgroundImage(UIImage.imageForNavigationBar(portrait: true), forBarMetrics: .Default)
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator:coordinator)
        
        var image: UIImage!
        if size.width > size.height {
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                image = UIImage.imageForNavigationBar(portrait: true)
            } else {
                image = UIImage.imageForNavigationBar(portrait: false)
            }
        } else {
            image = UIImage.imageForNavigationBar(portrait: true)
        }
        
        self.navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
    }
}

extension String {
    func integer() -> Int {
        if let objectInt = Int(self) {
            return objectInt
        } else {
            return 0
        }
    }
}