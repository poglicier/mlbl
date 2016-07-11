//
//  BaseController.swift
//  lementpro
//
//  Created by Valentin Shamardin on 05.02.16.
//  Copyright © 2016 Valentin Shamardin. All rights reserved.
//

import UIKit

class BaseController: UIViewController {

    var dataController: DataController!
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - Private
    
    private func hideTopBar(hide: Bool) {
        self.navigationController?.setNavigationBarHidden(hide, animated: true)
        UIApplication.sharedApplication().setStatusBarHidden(hide, withAnimation: .Slide)
    }
}

extension BaseController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if fabs(velocity.y) > 1 {
            self.hideTopBar(velocity.y > 0)
        }
    }
}