//
//  TMDbEndpoint.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import Foundation

/// An `enum` for creating endpoints to the TMDb services.
enum TMDbEndpoint: EndpointProvider {
    
    // MARK: - Endpoint Type
    struct Endpoint: EndpointConvertible {
        
        let path: String
        let client: ServiceFetcher.Client
        let queryItems: [URLQueryItem]
        
        /// Creates and returns an `Endpoint`.
        /// - Parameters:
        ///   - path: Path of the endpoint.
        ///   - client: `Client` of the endpoint.
        ///   - queryItems: Query parameters.
        init(
            path: String = "",
            client: ServiceFetcher.Client = Constants.Clients.api,
            queryItems: [URLQueryItem] = []
        ) {
            self.path = path
            self.client = client
            self.queryItems = queryItems
        }
    }
    
    // MARK: - Constants
    private enum Constants {
        static let apiKey = "2a61185ef6a27f400fd92820ad9e8537"
        
        enum Clients {
            static let api = ServiceFetcher.Client(scheme: "https", host: "api.themoviedb.org")
            static let images = ServiceFetcher.Client(scheme: "https", host: "image.tmdb.org")
        }
        
        enum ParameterKeys {
            static let apiKey = "api_key"
            static let query = "query"
        }
        
        enum Path {
            static let search = "/3/search/movie"
            static func details(movieID: String) -> String { "/3/movie/\(movieID)" }
            static func image(poster: String) -> String { "/t/p/w600_and_h900_bestv2\(poster)" }
        }
    }
    
    // MARK: - Endpoints
    /// Search endpoint.
    case search(query: String)
    /// Poster Image endpoint.
    case poster(posterName: String)
    /// Movie details endpoint.
    case details(movieID: String)
    
    func getEndpoint() -> EndpointConvertible {
        switch self {
        case .search(query: let query):
            // Currently there is no pagination implementation, but we can add some parameters related to that and implement pagination easily.
            return Endpoint(
                path: Constants.Path.search,
                queryItems: [
                    .init(name: Constants.ParameterKeys.apiKey, value: Constants.apiKey),
                    .init(name: Constants.ParameterKeys.query, value: query)
                ]
            )
        case .poster(let posterName):
            return Endpoint(
                path: Constants.Path.image(poster: posterName),
                client: Constants.Clients.images
            )
        case .details(let movieID):
            return Endpoint(
                path: Constants.Path.details(movieID: movieID),
                queryItems: [
                    .init(name: Constants.ParameterKeys.apiKey, value: Constants.apiKey)
                ]
            )
        }
    }
}
