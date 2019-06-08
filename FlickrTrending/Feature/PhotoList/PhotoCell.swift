//
//  PhotoCell.swift
//  FlickrTrending
//
//  Created by Kaka on 6/7/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var photoUrl: String? {
        didSet {
            loadView()
        }
    }
    
    private var aspectConstraint : NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                imageView.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                imageView.addConstraint(aspectConstraint!)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func loadView() {
        guard let photoUrl = self.photoUrl, let url = URL(string: photoUrl) else { return }
        imageView.sd_setImage(with: url, completed: nil)
    }
}
