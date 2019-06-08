//
//  PhotoListViewModel.swift
//  FlickrTrending
//
//  Created by Kaka on 6/6/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation

struct PhotoListViewModel {
    let id: String
    let photoUrl: String
    
    init(photo: InterestingPhoto) {
        self.id = photo.id ?? ""
        self.photoUrl = photo.photoUrl ?? ""
    }
}

extension PhotoListViewModel: Equatable {}

func ==(lhs: PhotoListViewModel, rhs: PhotoListViewModel) -> Bool {
    return lhs.id == rhs.id && lhs.photoUrl == rhs.photoUrl
}

