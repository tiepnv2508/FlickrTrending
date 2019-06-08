//
//  UIView+Util.swift
//  FlickrTrending
//
//  Created by Kaka on 6/8/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import UIKit

extension UIView {
//    func dropShadow(shadowColor: UIColor = UIColor.black,
//                    opacity: Float = 0.5,
//                    offset: CGSize = CGSize(width: 1.0, height: 2.0),
//                    radius: CGFloat = 10,
//                    cornerRadius: CGFloat = 15) {
//        // set the shadow of the view's layer
//        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius).cgPath
//        layer.shouldRasterize = true
//        layer.backgroundColor = UIColor.clear.cgColor
//        layer.shadowColor = shadowColor.cgColor
//        layer.shadowOffset = offset
//        layer.shadowOpacity = opacity
//        layer.shadowRadius = radius
//        
//        // set the cornerRadius of the containerView's layer
//        let containerView = UIView()
//        containerView.layer.cornerRadius = cornerRadius
//        containerView.layer.masksToBounds = true
//        
//        addSubview(containerView)
//    }
    
    func dropShadow(shadowColor: UIColor = UIColor.black,
                    fillColor: UIColor = UIColor.white,
                    opacity: Float = 0.8,
                    offset: CGSize = CGSize(width: 0.0, height: 1.0),
                    shadowRadius: CGFloat = 10,
                    cornerRadius: CGFloat = 15) {
        
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        shadowLayer.shouldRasterize = true
        shadowLayer.fillColor = fillColor.cgColor
        shadowLayer.shadowColor = shadowColor.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = offset
        shadowLayer.shadowOpacity = opacity
        shadowLayer.shadowRadius = shadowRadius
        layer.insertSublayer(shadowLayer, at: 0)
    }
}

