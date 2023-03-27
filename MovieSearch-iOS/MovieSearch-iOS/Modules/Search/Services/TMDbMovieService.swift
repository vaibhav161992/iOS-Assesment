//
//  TMDbMovieService.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import UIKit

/// A service class for TMDb.
class TMDbMovieService: TMDbService {
    
    // MARK: - MovieResults
    /// Response struct.
    private struct MovieResults: Decodable {
        let results: [Movie]?
    }
    
    private let movieCache: MovieItemCacheProvider
    
    init(
        serviceFetcher: ServiceFetchingProvider = ServiceFetcher(session: .shared),
        movieCache: MovieItemCacheProvider = MovieItemsStore(),
        imageCache: ImageCacheProvider = ImageCache.shared
    ) {
        self.movieCache = movieCache
        super.init(serviceFetcher: serviceFetcher, imageCache: imageCache)
    }
    
    // MARK: - Methods
    /// This function calls search API and returns results in completion.
    /// - Parameters:
    ///   - query: A search query.
    ///   - completion: Completion handler to be invoked with results.
    /// - Returns: A `ServiceTask` which can be cancelled.
    func searchMovies(withQuery query: String,
                      completion: @escaping ([MovieItem]?) -> Void) -> ServiceTask? {
        serviceFetcher.request(
            TMDbEndpoint.search(query: query),
            forType: MovieResults.self
        ) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let movieResults):
                let movieItems = movieResults.results?.compactMap { self.movieCache.movieItem(fromMovie: $0) }
                completion(movieItems)
                
            case .failure(let error):
                debugPrint(error.localizedDescription)
                guard !error.isCanceledExplicitly else { return }
                completion(nil)
            }
        }
    }
    
    func searchCachedMovies(withQuery query: String,
                            completion: @escaping ([MovieItem]?) -> Void) {
        movieCache.searchMovies(withQuery: query, completion: completion)
    }
}
