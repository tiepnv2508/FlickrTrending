//
//  Photo.swift
//  FlickrTrending
//
//  Created by Kaka on 6/6/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation
import CoreData

class Photo: NSManagedObject, Decodable {
    enum RootKeys: String, CodingKey {
        case photo
    }
    
    enum PhotoKeys: String, CodingKey {
        case id, dateUploaded = "dateuploaded", owner, title, description
    }
    
    enum OwnerKeys: String, CodingKey {
        case ownerName = "username"
    }
    
    enum DescriptionKeys: String, CodingKey {
        case desc = "_content"
    }
    
    enum TitleKeys: String, CodingKey {
        case title = "_content"
    }
    
    // MARK: - Core Data Managed Object
    @NSManaged var id: String?
    @NSManaged var title: String?
    @NSManaged var desc: String?
    @NSManaged var ownerName: String?
    @NSManaged var dateUploaded: String?
    
    // MARK: - Decodable
    required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Photo", in: managedObjectContext) else {
                fatalError("Failed to decode User")
        }

        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        // id, dateUploaded
        let photoContainer = try container.nestedContainer(keyedBy: PhotoKeys.self, forKey: .photo)
        self.id = try photoContainer.decode(String.self, forKey: .id)
        self.dateUploaded = try photoContainer.decode(String.self, forKey: .dateUploaded)
        
        // title
        let titleContainer = try photoContainer.nestedContainer(keyedBy: TitleKeys.self, forKey: .title)
        self.title = try titleContainer.decode(String.self, forKey: .title)
        
        // description
        let descContainer = try photoContainer.nestedContainer(keyedBy: DescriptionKeys.self, forKey: .description)
        self.desc = try descContainer.decode(String.self, forKey: .desc)
        
        // ownerName
        let ownerContainer = try photoContainer.nestedContainer(keyedBy: OwnerKeys.self, forKey: .owner)
        self.ownerName = try ownerContainer.decode(String.self, forKey: .ownerName)
    }
}
