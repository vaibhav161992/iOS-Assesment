//
//  Result.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import Foundation

extension ServiceFetchingProvider {
    typealias Result<Response: Decodable> = Swift.Result<Response, ServiceFetcher.Error>
}
