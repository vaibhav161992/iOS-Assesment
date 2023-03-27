//
//  TMDbService.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import UIKit

class TMDbService {
    
    // MARK: - Properties
    let serviceFetcher: ServiceFetchingProvider
    let imageCache: ImageCacheProvider
    
    // MARK: - Initializers
    /// Creates an instance of
    /// - Parameters:
    ///   - serviceFetcher: An object confirming to `ServiceFetchingProvider`.
    ///   - imageCache: An `ImageCache` for caching.
    init(serviceFetcher: ServiceFetchingProvider = ServiceFetcher(session: .shared),
         imageCache: ImageCacheProvider = ImageCache.shared) {
        self.serviceFetcher = serviceFetcher
        self.imageCache = imageCache
    }
    
    // MARK: - Image Caching Support
    /// Checks the cache and returns an image if found.
    /// - Parameter poster: A query for the poster.
    /// - Returns: An `UIImage` or `nil`.
    func localImage(forPoster poster: String) -> UIImage? {
        
        guard let url = try? self.endpoint(forPoster: poster).createURL(),
              let image = imageCache.image(forURL: url) else {
            return nil
        }
        
        return image
    }
    
    /// Fetches image from TMDb server.
    /// - Parameters:
    ///   - poster: A query for the poster.
    ///   - completion: Completion handler to be invoked with results.
    func image(forPoster poster: String,
               completion: @escaping (UIImage?) -> Void) {
        
        if let image = localImage(forPoster: poster) {
            completion(image)
            return
        }
        
        serviceFetcher.request(
            TMDbEndpoint.poster(posterName: poster),
            forType: Data.self
        ) { result in
            guard let data = try? result.get(),
                  let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            if let url = try? self.endpoint(forPoster: poster).createURL() {
                self.imageCache.set(
                    image: image,
                    forURL: url
                )
            }
            
            completion(image)
        }
    }
    
    // MARK: - Private Methods
    private func endpoint(forPoster poster: String) -> EndpointConvertible {
        TMDbEndpoint.poster(posterName: poster).getEndpoint()
    }
}
