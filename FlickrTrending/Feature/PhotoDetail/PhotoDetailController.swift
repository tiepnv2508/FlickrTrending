//
//  PhotoDetailController.swift
//  FlickrTrending
//
//  Created by Kaka on 6/7/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation
import CoreData
import Reachability

typealias FetchPhotoCompletion = (_ success: Bool, _ error: NSError?) -> Void

protocol PhotoDetailControllerProtocol {
    var item: PhotoDetailViewModel? { get }
    
    func fetchPhoto(_ completion: @escaping FetchPhotoCompletion)
}

extension PhotoDetailControllerProtocol {
    var item: PhotoDetailViewModel? {
        return item
    }
}

class PhotoDetailController: PhotoDetailControllerProtocol {
    private let entityName = "Photo"
    private var fetchPhotoCompletion: FetchPhotoCompletion?
    private let persistentContainer: NSPersistentContainer
    private let photoId: String
    
    var item: PhotoDetailViewModel?
    
    init(photoId: String, persistentContainer: NSPersistentContainer) {
        self.photoId = photoId
        self.persistentContainer = persistentContainer
    }
    
    func fetchPhoto(_ completion: @escaping FetchPhotoCompletion) {
        fetchPhotoCompletion = completion
        let reachability = Reachability()!
        if reachability.connection == .none {
            if let photo = fetchFromStorage() {
                // If have no internet connection, load from DB if it is existed in DB
                item = PhotoDetailController.initViewModel(photo)
                completion(true, nil)
            } else {
                completion(false, NSError.createError(0, description: "The Internet connection appear to be offline."))
            }
        } else {
            // If have a internet connection, load from API
            loadPhoto()
        }
    }
}

private extension PhotoDetailController {
    func fetchFromStorage() -> Photo? {
        let managedObjectContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Photo>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", photoId)
        do {
            let photo = try managedObjectContext.fetch(fetchRequest).first
            return photo
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func clearStorage() {
        let isInMemoryStore = persistentContainer.persistentStoreDescriptions.reduce(false) {
            return $0 ? true : $1.type == NSInMemoryStoreType
        }
        
        let managedObjectContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        // NSBatchDeleteRequest is not supported for in-memory stores
        if isInMemoryStore {
            do {
                let users = try managedObjectContext.fetch(fetchRequest)
                for user in users {
                    managedObjectContext.delete(user as! NSManagedObject)
                }
            } catch let error as NSError {
                print(error)
            }
        } else {
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try managedObjectContext.execute(batchDeleteRequest)
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    static func initViewModel(_ photo: Photo) -> PhotoDetailViewModel {
        return PhotoDetailViewModel(photo: photo)
    }
    
    func loadPhoto() {
        FlickrService.shared.fetchPhotoInfo(photoId: photoId, context: persistentContainer.viewContext) { [weak self](result) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(_):
                if let photo = strongSelf.fetchFromStorage() {
                    let newPhoto = PhotoDetailController.initViewModel(photo)
                    strongSelf.item = newPhoto
                }
                strongSelf.fetchPhotoCompletion?(true, nil)
            case .failure(let error):
                strongSelf.fetchPhotoCompletion?(false, NSError.createError(0, description: error.description))
            }
        }
    }
}
