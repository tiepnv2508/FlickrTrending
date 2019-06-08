//
//  NSError+Util.swift
//  FlickrTrending
//
//  Created by Kaka on 6/7/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation

extension NSError {
    static func createError(_ code: Int, description: String) -> NSError {
        return NSError(domain: "com.tiep.FlickrTrending",
                       code: code,
                       userInfo: [
                        "NSLocalizedDescription" : description
            ])
    }
}
