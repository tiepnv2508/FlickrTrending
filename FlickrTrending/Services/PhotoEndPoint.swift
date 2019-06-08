//
//  PhotoEndPoint.swift
//  FlickrTrending
//
//  Created by Kaka on 6/7/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//

import Foundation

enum PhotoEndPoint {
    case photo(id: String)
    case interestingPhoto(date: String, offset: Int, page: Int)
}

enum Method: String{
    case interestingness = "flickr.interestingness.getList"
    case photoInfo = "flickr.photos.getInfo"
}

extension PhotoEndPoint {
    var baseURL: URL {
        guard let url = URL(string: "https://www.flickr.com/services/rest/") else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    func provideValues() -> (url: URL, params: [URLQueryItem]) {
        switch self {
        case .photo(let id):
            return (url: baseURL, params: parameters(method: Method.photoInfo.rawValue, photoId: id))
        case .interestingPhoto(let date, let offset, let page):
            return (url: baseURL, params: parameters(method: Method.interestingness.rawValue, date: date, offset: offset, page: page))
        }
    }
    
    // MARK: - Private methods
    private func parameters(method: String, photoId: String)-> [URLQueryItem] {
        return [
            URLQueryItem(name: "method", value: method),
            URLQueryItem(name: "photo_id", value: photoId)
        ]
    }
    
    private func parameters(method: String, date: String, offset: Int, page: Int) -> [URLQueryItem] {
        return [
            URLQueryItem(name: "method", value: method),
            URLQueryItem(name: "date", value: date),
            URLQueryItem(name: "per_page", value: String(offset)),
            URLQueryItem(name: "page", value: String(page))
        ]
    }
}
