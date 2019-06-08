//
//  UIViewController+Util.swift
//  FlickrTrending
//
//  Created by Kaka on 6/6/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import UIKit

extension UIViewController {
    func showError(_ title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
}
