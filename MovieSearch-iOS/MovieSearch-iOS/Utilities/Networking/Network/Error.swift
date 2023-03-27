//
//  Error.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import Foundation

extension ServiceFetcher {
    
    /// An specialised error type for `ServiceFetcher`
    enum Error: Swift.Error {
        case invalidURL(url: String)
        case unableToDecode(data: Data)
        case unableToEncode
        case network(_ error: NSError?)
        case otherError(_ error: Swift.Error)
        
        /// Indicates if request was cancelled explicitly.
        var isCanceledExplicitly: Bool {
            guard case let .network(error) = self else {
                return false
            }
            return error?.code == NSURLErrorCancelled
        }
    }
}

extension ServiceFetcher.Error: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "The URL provided \"\(url)\" is invalid."
            
        case .unableToDecode(let data):
            let description = String(data: data, encoding: .utf8)
                .flatMap({"\n\($0)\n"}) ?? "of length \(data.count)"
            return "Unable to decode the received data: \(description)."
            
        case .unableToEncode:
            return "Unable to encode given type."
            
        case .network(let error):
            return "Network error: \(error?.userInfo.description ?? "")"
            
        case .otherError(let error):
            return "Other error: \(error.localizedDescription)"
        }
    }
}
