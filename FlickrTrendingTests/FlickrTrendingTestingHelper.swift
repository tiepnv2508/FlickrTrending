//
//  FlickrTrendingTestingHelper.swift
//  FlickrTrendingTests
//
//  Created by Kaka on 6/8/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import XCTest
import CoreData
import OHHTTPStubs

@testable import FlickrTrending

class FlickrTrendingTestingHelper {
    lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
        return managedObjectModel
    }()
    
    lazy var mockPersistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FlickrTrending", managedObjectModel: managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { (description, error) in
            precondition(description.type == NSInMemoryStoreType)
            if let error = error {
                XCTFail("Error creating the in-memory NSPersistentContainer mock: \(error)")
            }
        }
        
        return container
    }()
    
    func stubResponse(for fileName: String, statusCode: Int32 = 200) -> OHHTTPStubsResponse {
        let bundle = Bundle(for: type(of: self))
        let path = OHPathForFileInBundle(fileName, bundle)
        let result = OHHTTPStubsResponse(fileAtPath: path!,
                                         statusCode: statusCode,
                                         headers: ["Content-Type": "application/json"])
        return result
    }
    
    func jsonData(for fileName: String) -> Data? {
        let bundle = Bundle(for: type(of: self))
        if let path = OHPathForFileInBundle(fileName, bundle) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                return data
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        }
        return nil
    }
    
    func numberOfItemsInPersistentStore(for entityName: String) -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let results = try! mockPersistentContainer.viewContext.fetch(request)
        return results.count
    }
    
    func foundItemWith(key: String, value: String, entityName: String) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = NSPredicate(format: "%@ == %@", key, value)
        let results = try! mockPersistentContainer.viewContext.fetch(request)
        return results.count > 0
    }
    
    func clearStorage(for entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let context = mockPersistentContainer.viewContext
        let objs = try! context.fetch(fetchRequest)
        for case let obj as NSManagedObject in objs {
            context.delete(obj)
        }
        try! context.save()
    }
}
