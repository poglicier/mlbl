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
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3;
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) {
            if self.presenting {
                transitionContext.containerView()?.addSubview(toViewController.view)
                toViewController.view.alpha = 0
                
                UIView.animateWithDuration(self.transitionDuration(transitionContext),
                    animations: { () -> Void in
                    toViewController.view.alpha = 1
                    },
                    completion: { (Bool) -> Void in
                        transitionContext.completeTransition(transitionContext.transitionWasCancelled() == false)
                })
            }
            else {
                if let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) {
                    fromViewController.view.alpha = 1
                    
                    UIView.animateWithDuration(self.transitionDuration(transitionContext),
                        animations: { () -> Void in
                            fromViewController.view.alpha = 0
                        },
                        completion: { (Bool) -> Void in
                            transitionContext.completeTransition(transitionContext.transitionWasCancelled() == false)
                    })
                }
            }
        }
    }
}