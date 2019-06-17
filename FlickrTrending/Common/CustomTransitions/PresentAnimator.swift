//
//  PresentAnimator.swift
//  FlickrTrending
//
//  Created by Kaka on 6/8/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import UIKit

class PresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let toViewController = transitionContext.viewController(forKey: .to)!
        
        // Config layout
        do {
            toView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(toView)
            // set bottom margin = 20
            let bottom = max(20 - toView.safeAreaInsets.bottom, 0)
            containerView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: toView.bottomAnchor, constant: bottom).isActive = true
            containerView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: -20).isActive = true
            containerView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 20).isActive = true
            
            // Dim background view
            containerView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            
            // set heightAnchor constraint if preferredContentSize.height > 0
            toViewController.preferredContentSize.height = toView.frame.size.height/2
            if toViewController.preferredContentSize.height > 0 {
                toView.heightAnchor.constraint(equalToConstant: toViewController.preferredContentSize.height).isActive = true
            }
        }
        
        // Perform animation
        do {
            containerView.layoutIfNeeded()
            let originalY = toView.frame.origin.y
            toView.frame.origin.y += containerView.frame.height - toView.frame.minY
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                toView.frame.origin.y = originalY
            }) { (completed) in
                transitionContext.completeTransition(completed)
            }
        }
    }
}
