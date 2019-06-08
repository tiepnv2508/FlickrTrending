//
//  PhotoListController.swift
//  FlickrTrending
//
//  Created by Kaka on 6/7/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation
import CoreData
import Reachability

typealias FetchPhotosCompletion = (_ success: Bool, _ error: NSError?) -> Void

protocol PhotoListControllerProtocol {
    var items: [PhotoListViewModel?]? { get }
    
    func fetchPhotos(_ completion: @escaping FetchPhotosCompletion)
    func fetchMore(_ completion: @escaping FetchPhotosCompletion)
}

extension PhotoListControllerProtocol {
    var items: [PhotoListViewModel?]? {
        return items
    }
}

class PhotoListController: PhotoListControllerProtocol {
    private let pageSize = 10
    private let entityName = "InterestingPhoto"
    
    private let persistentContainer: NSPersistentContainer
    
    private var currentPage = 0
    private var lastPage = 0
    private var maximumPage = 0
    private var noMoreData = false
    
    private var fetchPhotosCompletion: FetchPhotosCompletion?
    private var fetchMoreCompletion: FetchPhotosCompletion?
    
    lazy var yesterday: String? = {
        return Date.yesterdayString()
    }()
    
    var items: [PhotoListViewModel?]? = []
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func fetchPhotos(_ completion: @escaping FetchPhotosCompletion) {
        fetchPhotosCompletion = completion
        resetIndex()
        
        let reachability = Reachability()!
        if reachability.connection == .none {
            // If have no internet connection, load from DB
            if let interestingPhotos = self.fetchFromStorage(),
                interestingPhotos.count > 0 {
                let photosPage = PhotoListController.initViewModels(interestingPhotos)
                items?.append(contentsOf: photosPage)
                completion(true, nil)
            } else {
                completion(false, NSError.createError(0, description: "The Internet connection appears to be offline."))
            }
            
            // Start notifier to catch whenever internet connection reachable
            do {
                try reachability.startNotifier()
            } catch {
                print("Unable to start notifier")
            }
        } else {
            // If have a internet connection, load from API
            loadNextPageIfNeeded()
        }
        
        // Update new data whenever connection reachable
        reachability.whenReachable = { [weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.loadNextPageIfNeeded()
            
            // Stop notifier whenever updated latest data
            reachability.stopNotifier()
        }
    }
    
    func fetchMore(_ completion: @escaping FetchPhotosCompletion) {
        fetchMoreCompletion = completion
        loadNextPageIfNeeded()
    }
}

private extension PhotoListController {
    func fetchFromStorage() -> [InterestingPhoto]? {
        let managedObjectContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<InterestingPhoto>(entityName: entityName)
        do {
            let photos = try managedObjectContext.fetch(fetchRequest)
            return photos
        } catch let error {
            print(error.localizedDescription)
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
    
    func resetIndex() {
        currentPage = 0
        lastPage = 0
        maximumPage = 0
        noMoreData = false
    }
    
    static func initViewModels(_ photos: [InterestingPhoto?]) -> [PhotoListViewModel?] {
        return photos.map { photo in
            guard let photo = photo else { return nil }
            return PhotoListViewModel(photo: photo)
        }
    }
    
    func loadNextPageIfNeeded() {
        if noMoreData { return }
        
        currentPage += 1
        
        // Clear storage in the first time
        if currentPage == 1 {
            clearStorage()
            items?.removeAll()
        } else {
            // Reached maximum page => no more data to load
            if currentPage > maximumPage {
                noMoreData = true
                return
            }
        }
        
        guard let yesterday = yesterday else { return }
        
        FlickrService.shared.fetchInterestingPhoto(date: yesterday, offset: pageSize, page: currentPage, context: persistentContainer.viewContext) { [weak self] (result) in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let response):
                strongSelf.lastPage += 1
                strongSelf.maximumPage = response.maximumPage ?? 0
                let newPhotosPage = PhotoListController.initViewModels(response.photoList)
                strongSelf.items?.append(contentsOf: newPhotosPage)
                strongSelf.fetchPhotosCompletion?(true, nil)
            case .failure(let error):
                strongSelf.fetchPhotosCompletion?(false, NSError.createError(0, description: error.description))
            }
        }
    }
}
