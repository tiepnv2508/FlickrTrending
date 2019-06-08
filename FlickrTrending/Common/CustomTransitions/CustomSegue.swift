//
//  CustomSegue.swift
//  FlickrTrending
//
//  Created by Kaka on 6/7/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import UIKit

class CustomSegue: UIStoryboardSegue {
    private var strongSelf: CustomSegue? = nil
    
    override func perform() {
        strongSelf = self
        destination.modalPresentationStyle = .overCurrentContext
        destination.transitioningDelegate = self
        source.present(destination, animated: true, completion: nil)
    }
}

extension CustomSegue: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentAnimator()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        strongSelf = nil
        return DismissAnimator()
    }
}
