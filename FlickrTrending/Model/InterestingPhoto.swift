//
//  InterestingPhoto.swift
//  FlickrTrending
//
//  Created by Kaka on 6/7/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation
import CoreData

class InterestingPhoto: NSManagedObject {
    // MARK: - Core Data Managed Object
    @NSManaged var id: String?
    @NSManaged var photoUrl: String?
}

struct InterestingPhotoResponse: Decodable {
    // Raw response from server
    enum RootKeys: String, CodingKey {
        case photos
    }
    
    enum PhotosKeys: String, CodingKey {
        case photo, maximumPage = "pages"
    }
    
    enum PhotoInfo: String, CodingKey {
        case id, secret, server, farm
    }
    
    var photoList: [InterestingPhoto] = []
    var maximumPage: Int?
    
    // MARK: - Decodable
    init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let _ = NSEntityDescription.entity(forEntityName: "InterestingPhoto", in: managedObjectContext) else {
                fatalError("Failed to decode User")
        }
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        let photosContainer = try container.nestedContainer(keyedBy: PhotosKeys.self, forKey: .photos)
        self.maximumPage = try photosContainer.decode(Int.self, forKey: .maximumPage)
        
        var photoUnkeyedContainer = try photosContainer.nestedUnkeyedContainer(forKey: .photo)
        while !photoUnkeyedContainer.isAtEnd {
            let photoInfoContainer = try photoUnkeyedContainer.nestedContainer(keyedBy: PhotoInfo.self)
            let id = try photoInfoContainer.decode(String.self, forKey: .id)
            let secret = try photoInfoContainer.decode(String.self, forKey: .secret)
            let server = try photoInfoContainer.decode(String.self, forKey: .server)
            let farm = try photoInfoContainer.decode(Int.self, forKey: .farm)
            let photoUrl = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
            
            let photo = InterestingPhoto(context: managedObjectContext)
            photo.id = id
            photo.photoUrl = photoUrl
            photoList.append(photo)
        }
    }
}
