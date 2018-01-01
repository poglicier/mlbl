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
    var pushesController: PushesController!
    fileprivate(set) var activityView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupActivityView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.willEnterForegroud), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Private
    
    fileprivate func hideTopBar(_ hide: Bool) {
        self.navigationController?.setNavigationBarHidden(hide, animated: true)
    }
    
    fileprivate func setupActivityView() {
        let av = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        av.hidesWhenStopped = true
        av.color = UIColor.mlblLightOrangeColor()
        self.view.addSubview(av)
        av.snp.makeConstraints { (make) in
            make.center.equalTo(self.view.snp.center)
        }
        av.isHidden = true
        
        self.activityView = av
    }
    
    // MARK: - Public
    
    @objc func willEnterForegroud() {
        
    }
}

extension BaseController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if fabs(velocity.y) > 1 {
            self.hideTopBar(velocity.y > 0)
        }
    }
}
