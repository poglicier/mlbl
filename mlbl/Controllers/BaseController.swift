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
    private(set) var activityView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupActivityView()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - Private
    
    private func hideTopBar(hide: Bool) {
        self.navigationController?.setNavigationBarHidden(hide, animated: true)
    }
    
    private func setupActivityView() {
        let av = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        av.hidesWhenStopped = true
        av.color = UIColor.mlblLightOrangeColor()
        self.view.addSubview(av)
        av.snp_makeConstraints { (make) in
            make.centerX.equalTo(0)
            make.centerY.equalTo(0)
        }
        av.hidden = true
        
        self.activityView = av
    }
}

extension BaseController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if fabs(velocity.y) > 1 {
            self.hideTopBar(velocity.y > 0)
        }
    }
}