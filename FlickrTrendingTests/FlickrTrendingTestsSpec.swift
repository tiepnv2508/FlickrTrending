//
//  FlickrTrendingTestsSpec.swift
//  FlickrTrendingTests
//
//  Created by Kaka on 6/8/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation
import Quick
import Nimble
import CoreData
import OHHTTPStubs

@testable import FlickrTrending

class FlickrTrendingTestsSpec: QuickSpec {
    private static let entityPhoto = "Photo"
    private static let entityInterestingPhoto = "InterestingPhoto"
    
    var testingHelper: FlickrTrendingTestingHelper!
    var photoListController: PhotoListController!
    var photoDetailController: PhotoDetailController!
    
    override func spec() {
        super.spec()
        
        beforeEach {
            self.testingHelper = FlickrTrendingTestingHelper()
        }
        
        describe("Test PhotoListController") {
            beforeEach{
                self.testingHelper.clearStorage(for: FlickrTrendingTestsSpec.entityInterestingPhoto)
                self.photoListController = PhotoListController(persistentContainer: self.testingHelper.mockPersistentContainer)

                OHHTTPStubs.stubRequests(passingTest: { request in
                    return request.url!.path.contains("flickr.interestingness.getList")
                }, withStubResponse: { _ in
                    return self.testingHelper.stubResponse(for: "interestingPhotos", statusCode: 200)
                })
            }
            
            context("Test FetchCompletion") {
                it("Return true and insert numbers of records to persistent store") {
                    self.photoListController.fetchPhotos({ (result, error) in
                        expect(error).to(beNil())
                        expect(result).to(beTrue())
                        
                        let numOfRecord = self.testingHelper.numberOfItemsInPersistentStore(for: FlickrTrendingTestsSpec.entityInterestingPhoto)
                        expect(self.photoListController.items?.count)
                            .to(equal(numOfRecord))
                    })
                }
            }
            
            context("Test fetch photos match") {
                it("Return expected photos") {
                    let expectedPhotos: [PhotoListViewModel]
                    let jsonData = self.testingHelper.jsonData(for: "interestingPhotos.json")
                    do {
                        let managedObjectContext = self.testingHelper.mockPersistentContainer.viewContext
                        let decoder = JSONDecoder()
                        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
                            fatalError("Failed to retrieve managed object context")
                        }
                        decoder.userInfo[codingUserInfoKeyManagedObjectContext] = managedObjectContext
                        let response = try decoder.decode(InterestingPhotoResponse.self, from: jsonData!)
                        expectedPhotos = response.photoList.map { photo in
                            let expected = PhotoListViewModel(photo: photo)
                            expect(expected).notTo(beNil())
                            return expected
                        }
                        self.testingHelper.clearStorage(for: FlickrTrendingTestsSpec.entityInterestingPhoto)
                    } catch let error {
                        fatalError(error.localizedDescription)
                    }
                    
                    self.photoListController.fetchPhotos({ (_, _) in
                        let numOfRecord = self.testingHelper.numberOfItemsInPersistentStore(for: FlickrTrendingTestsSpec.entityInterestingPhoto)
                        expect(self.photoListController.items?.count).to(equal(numOfRecord))
                        
                        for index in 0..<self.photoListController.items!.count {
                            let actualPhoto = self.photoListController.items![index]
                            expect(actualPhoto).notTo(beNil())
                            expect(actualPhoto).to(equal(expectedPhotos[index]))
                        }
                    })
                }
            }
        }
        
        describe("Test PhotoDetailController") {
            let photoId = "48006020976"
            beforeEach{
                self.testingHelper.clearStorage(for: FlickrTrendingTestsSpec.entityPhoto)
                self.photoDetailController = PhotoDetailController(photoId: photoId, persistentContainer: self.testingHelper.mockPersistentContainer)

                OHHTTPStubs.stubRequests(passingTest: { request in
                    return request.url!.path.contains("flickr.photos.getInfo")
                }, withStubResponse: { _ in
                    return self.testingHelper.stubResponse(for: "photo", statusCode: 200)
                })
            }

            context("Test FetchCompletion") {
                it("Return true and insert record with photoId to persistent store") {
                    self.photoDetailController.fetchPhoto({ (result, error) in
                        expect(error).to(beNil())
                        expect(result).to(beTrue())
                        
                        let foundItem = self.testingHelper.foundItemWith(key: "id", value: photoId, entityName: FlickrTrendingTestsSpec.entityPhoto)
                        expect(foundItem).to(beTrue())
                    })
                }
            }

            context("Test fetch photo match") {
                it("Return expected photo") {
                    let expectedPhoto: PhotoDetailViewModel
                    let jsonData = self.testingHelper.jsonData(for: "photo.json")
                    do {
                        let managedObjectContext = self.testingHelper.mockPersistentContainer.viewContext
                        let decoder = JSONDecoder()
                        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
                            fatalError("Failed to retrieve managed object context")
                        }
                        decoder.userInfo[codingUserInfoKeyManagedObjectContext] = managedObjectContext
                        let photo = try decoder.decode(Photo.self, from: jsonData!)
                        expectedPhoto = PhotoDetailViewModel.init(photo: photo)
                        self.testingHelper.clearStorage(for: FlickrTrendingTestsSpec.entityPhoto)
                    } catch let error {
                        fatalError(error.localizedDescription)
                    }
                    
                    self.photoDetailController.fetchPhoto({ (_, _) in
                        let foundItem = self.testingHelper.foundItemWith(key: "id", value: photoId, entityName: FlickrTrendingTestsSpec.entityPhoto)
                        expect(foundItem).to(beTrue())
                        
                        let actualPhoto = self.photoDetailController.item
                        expect(actualPhoto).to(equal(expectedPhoto))
                    })
                }
            }
        }
    }
}
