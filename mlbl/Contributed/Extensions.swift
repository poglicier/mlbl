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
        return String(describing: self)
    }
    
    class func deleteAll(in context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: self.entityName())
        do {
            let objects = try context.fetch(fetchRequest)
            for object in objects {
                context.delete(object)
            }
        } catch {}
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
    static func imageWithView(_ view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
    }
    
    static func imageForNavigationBar(portrait: Bool) -> UIImage {
        if portrait == true {
            let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
            
            if statusBarHeight > 20 {
                // iPhoneX
                UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
                let context = UIGraphicsGetCurrentContext()
                
                let rect1 = CGRect(x: 0, y: 0, width: 1, height: 1)
                let color1 = UIColor.mlblLightOrangeColor()
                
                context?.setFillColor(color1.cgColor)
                context?.fill(rect1)
            } else {
                let topBarHeight: CGFloat = 64
                UIGraphicsBeginImageContext(CGSize(width: 1, height: topBarHeight))
                let context = UIGraphicsGetCurrentContext()
                
                let rect1 = CGRect(x: 0, y: 0, width: 1, height: statusBarHeight)
                let color1 = UIColor.mlblDarkOrangeColor()
                let rect2 = CGRect(x: 0, y: statusBarHeight, width: 1, height: topBarHeight - statusBarHeight)
                let color2 = UIColor.mlblLightOrangeColor()
                
                context?.setFillColor(color1.cgColor)
                context?.fill(rect1)
                context?.setFillColor(color2.cgColor)
                context?.fill(rect2)
            }
        } else {
            let rect2 = CGRect(x: 0, y: 0, width: 1, height: 44)
            UIGraphicsBeginImageContext(rect2.size)
            
            let context = UIGraphicsGetCurrentContext()
            let color2 = UIColor.mlblLightOrangeColor()
            
            context?.setFillColor(color2.cgColor)
            context?.fill(rect2)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func imageWithColor(_ color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()
        
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0);
        context?.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height) as CGRect
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension UINavigationController: UINavigationControllerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white]
        self.navigationBar.setBackgroundImage(UIImage.imageForNavigationBar(portrait: true), for: .default)
        self.delegate = self
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with:coordinator)
        
        var image: UIImage!
        if size.width > size.height {
            if UIDevice.current.userInterfaceIdiom == .pad {
                image = UIImage.imageForNavigationBar(portrait: true)
            } else {
                image = UIImage.imageForNavigationBar(portrait: false)
            }
        } else {
            image = UIImage.imageForNavigationBar(portrait: true)
        }
        
        self.navigationBar.setBackgroundImage(image, for: .default)
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if toVC is ChooseCompetitionController {
            let animator = FadeAnimator()
            animator.presenting = true
            return animator
        } else {
            return nil
        }
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
    
    fileprivate subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String? {
        if self.count < i {
            return String(self[i] as Character)
        } else {
            return nil
        }
    }
    
    func firstLetter() -> String? {
        return self[0]
    }
}

extension UIFont {
    func sizeOfString(string: NSString, constrainedToWidth width: CGFloat) -> CGSize {
        return string.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                                   options: .usesLineFragmentOrigin,
                                   attributes: [.font: self],
                                   context: nil).size
    }
}
