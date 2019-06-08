//
//  APIServiceError.swift
//  FlickrTrending
//
//  Created by Kaka on 6/6/19.
//  Copyright © 2019 Tiep Nguyen. All rights reserved.
//
import Foundation
public enum APIServiceError: CustomStringConvertible, Error {
    case customError(_ message: String)
    case apiError
    case invalidEndpoint
    case invalidResponse
    case noData
    case decodeError
    
    public var description : String {
        switch self {
        case .customError(let message): return message
        case .apiError: return "API error"
        case .invalidEndpoint: return "Invalid enpoint"
        case .invalidResponse: return "Invalid response"
        case .noData: return "No data"
        case .decodeError: return "Decode error"
        }
    }
}

