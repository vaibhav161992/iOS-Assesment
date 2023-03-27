//
//  TMDbMovieDetailsService.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import Foundation

/// A service class for TMDb.
class TMDbMovieDetailsService: TMDbService {
    
    let movieCache: MovieItemCacheProvider
    
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
    @discardableResult
    func fetchMovieDetails(withID movieID: Int,
                           completion: @escaping (MovieItem?) -> Void) -> ServiceTask? {
        serviceFetcher.request(
            TMDbEndpoint.details(movieID: "\(movieID)"),
            forType: MovieDetails.self
        ) { [weak self] response in
            guard let self else { return }
            
            switch response {
            case .success(let response):
                completion(self.movieCache.movieItem(fromMovieDetails: response))
                
            case .failure(let error):
                debugPrint(error.localizedDescription)
                guard !error.isCanceledExplicitly else { return }
                completion(nil)
            }
        }
    }
}
