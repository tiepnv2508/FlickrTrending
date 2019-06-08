//
//  PhotoViewModel.swift
//  FlickrTrending
//
//  Created by Kaka on 6/6/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation

struct PhotoDetailViewModel {
    let id: String?
    let title: String?
    let desc: String?
    let ownerName: String?
    let dateUploaded: String?
    
    init(photo: Photo) {
        self.id = photo.id ?? ""
        self.title = photo.title ?? ""
        self.ownerName = photo.ownerName ?? ""
        self.dateUploaded = photo.dateUploaded ?? ""
        self.desc = photo.desc ?? ""
    }
}

extension PhotoDetailViewModel: Equatable {}

func ==(lhs: PhotoDetailViewModel, rhs: PhotoDetailViewModel) -> Bool {
    return lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.ownerName == rhs.ownerName &&
        lhs.dateUploaded == rhs.dateUploaded &&
        lhs.desc == rhs.desc
}
