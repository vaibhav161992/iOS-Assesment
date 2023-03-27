//
//  EndpointConvertible.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import Foundation

/// A protocol for endpoint creation.
protocol EndpointConvertible {
    
    var path: String { get }
    var client: ServiceFetcher.Client { get }
    var queryItems: [URLQueryItem] { get }
    var httpMethod: ServiceFetcher.HTTPMethod { get }
    var headers: [String: String] { get }
    
    func httpBody() throws -> Data?
    func urlRequest() throws -> URLRequest
}

/// A protocol that can provide endpoint.
protocol EndpointProvider {
    func getEndpoint() -> EndpointConvertible
}

// MARK: - EndpointConvertible Methods
extension EndpointConvertible {
    func createURL() throws -> URL {
        var components = URLComponents()
        components.scheme = client.scheme
        components.host = client.host
        components.path = path
        components.queryItems = queryItems

        guard let url = components.url else {
            throw ServiceFetcher.Error.invalidURL(
                url: components.debugDescription
            )
        }
        return url
    }
    
    func urlRequest() throws -> URLRequest {
        let url = try createURL()
        var request = URLRequest(url: url)
        request.httpBody = try httpBody()
        request.httpMethod = httpMethod.rawValue
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        return request
    }
}

// MARK: - Default Implementations
extension EndpointConvertible {
    var queryItems: [URLQueryItem] { [] }
    var httpMethod: ServiceFetcher.HTTPMethod { .get }
    var headers: [String: String] { [:] }
    
    func httpBody() throws -> Data? { nil }
}
