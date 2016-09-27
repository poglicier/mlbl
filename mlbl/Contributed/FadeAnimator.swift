//
//  FadeAnimator.swift
//  lementpro
//
//  Created by Valentin Shamardin on 21.10.15.
//  Copyright © 2015 Valentin Shamardin. All rights reserved.
//

import UIKit

class FadeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var presenting = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3;
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) {
            if self.presenting {
                transitionContext.containerView.addSubview(toViewController.view)
                toViewController.view.alpha = 0
                
                UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                    animations: { () -> Void in
                    toViewController.view.alpha = 1
                    },
                    completion: { (Bool) -> Void in
                        transitionContext.completeTransition(transitionContext.transitionWasCancelled == false)
                })
            }
            else {
                if let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) {
                    fromViewController.view.alpha = 1
                    
                    UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                        animations: { () -> Void in
                            fromViewController.view.alpha = 0
                        },
                        completion: { (Bool) -> Void in
                            transitionContext.completeTransition(transitionContext.transitionWasCancelled == false)
                    })
                }
            }
        }
    }
}
