//
//  HTTPMethod.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import Foundation

extension ServiceFetcher {
    
    /// HTTP methods to be used in request.
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }
}
