//
//  FlickrService.swift
//  FlickrTrending
//
//  Created by Kaka on 6/6/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation
import CoreData

class FlickrService {
    public static let shared = FlickrService()
    private init() {}
    private let urlSession = URLSession.shared
    private let apiKey = "c3bbf23b70d5da7ddd81a5bb3c68a92a"
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
    
    private func fetchResources<T: Decodable>(url: URL, params: [URLQueryItem], context: NSManagedObjectContext, completion: @escaping (Result<T, APIServiceError>) -> Void) {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        let defaultParams = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1")
        ]
        
        urlComponents.queryItems = defaultParams + params
        
        guard let url = urlComponents.url else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        urlSession.dataTask(with: url) { (result) in
            switch result {
            case .success(let (response, data)):
                //If success, we retrieve the data then check the response HTTP status code
                //to make sure it’s in the range between 200 and 299
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                    DispatchQueue.main.async {
                        completion(.failure(.invalidResponse))
                    }
                    return
                }
                do {
                    guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
                        fatalError("Failed to retrieve managed object context")
                    }
                    self.jsonDecoder.userInfo[codingUserInfoKeyManagedObjectContext] = context
                    let values = try self.jsonDecoder.decode(T.self, from: data)
                    try context.save()
                    DispatchQueue.main.async {
                        completion(.success(values))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.decodeError))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(.customError(error.localizedDescription)))
                }
            }
        }.resume()
    }
    
    //****************************************************
    //* Fetch Interesting Photo
    //* Params: date, offset, page, context
    //* Return values: InterestingPhotoResponse
    //****************************************************
    public func fetchInterestingPhoto(date: String, offset: Int, page: Int, context: NSManagedObjectContext, result: @escaping (Result<InterestingPhotoResponse, APIServiceError>) -> Void) {
        let values = PhotoEndPoint.interestingPhoto(date: date, offset: offset, page: page).provideValues()
        fetchResources(url: values.url, params: values.params, context: context, completion: result)
    }
    
    //****************************************************
    //* Get photo infomation by photoId
    //* Params: photoId, context
    //* Return values: Photo
    //****************************************************
    public func fetchPhotoInfo(photoId: String, context: NSManagedObjectContext, result: @escaping (Result<Photo, APIServiceError>) -> Void) {
        let values = PhotoEndPoint.photo(id: photoId).provideValues()
        fetchResources(url: values.url, params: values.params, context: context, completion: result)
    }
}

