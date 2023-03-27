//
//  MovieSearchViewModel.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import UIKit

/// A delegate protocol to integrate with the `MovieSearchViewModel`.
protocol MovieSearchViewModelDelegate: AnyObject {
    /// Reload all the data.
    func reloadData()
    
    /// Reload only specific item in the list.
    /// - Parameter indexPath: An `IndexPath` of the item.
    func reloadItem(atIndexPath indexPath: IndexPath)
}

protocol MovieSearchViewModelProvider: AnyObject {
    // MARK: Properties
    /// A delegate object who responds to all the events.
    var delegate: MovieSearchViewModelDelegate? { get set }
    /// Search text on basis of which the view model will perform search.
    var searchText: String? { get set }
    /// Returns number of items.
    var numberOfItems: Int { get }
    
    /// Creates and returns the view model for the cell.
    /// - Parameter indexPath: An `IndexPath` of the requested item.
    /// - Returns: An instance of `MovieItemViewModel`.
    func movieItem(atIndexPath indexPath: IndexPath) -> MovieItemViewModel
    
    /// Returns `Movie` at given indexPath.
    /// - Parameter indexPath: An `IndexPath` of the requested item.
    /// - Returns: An Identifier for a `Movie`.
    func movieID(atIndexPath indexPath: IndexPath) -> Int64
}

class MovieSearchViewModel {
    
    // MARK: Properties
    private var movies: [MovieItem] = []
    private let tmdbService: TMDbMovieService
    private let reachability: NetworkReachabilityProvider
    private var lastSearchRequest: ServiceTask?
    private let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
    
    // MARK: Properties
    weak var delegate: MovieSearchViewModelDelegate?
    var searchText: String? {
        didSet {
            updateResults()
        }
    }
    // MARK: - Initializers
    /// Creates an instance of `MovieSearchViewModel`.
    /// - Parameter tmdbService: An instance of `TMDbService`.
    init(
        tmdbService: TMDbMovieService = .init(),
        reachability: NetworkReachabilityProvider = AppDelegate.shared
    ) {
        self.tmdbService = tmdbService
        self.reachability = reachability
    }
    
    // MARK: - Private Methods
    private func getImageOrLoad(atIndexPath indexPath: IndexPath, movie: MovieItem) -> UIImage? {
        
        guard let posterPath = movie.posterPath else { return nil }
        
        guard let image = tmdbService.localImage(forPoster: posterPath) else {
            guard reachability.isNetworkReachable else { return nil }
            tmdbService.image(forPoster: posterPath) { [weak self] _ in
                guard let self = self,
                      self.numberOfItems > indexPath.row else {
                    return
                }
                self.delegate?.reloadItem(atIndexPath: indexPath)
            }
            return nil
        }
        return image
    }
    
    private func updateResults() {
        guard let searchText = searchText else { return }
        
        lastSearchRequest?.cancel()
        lastSearchRequest = nil
        
        if reachability.isNetworkReachable {
            lastSearchRequest = tmdbService.searchMovies(withQuery: searchText) { [weak self] movies in
                self?.movies = movies ?? []
                self?.delegate?.reloadData()
            }
        } else {
            tmdbService.searchCachedMovies(withQuery: searchText) { [weak self] movies in
                self?.movies = movies ?? []
                self?.delegate?.reloadData()
            }
        }
    }
}

// MARK: - MovieSearchViewModelProvider
extension MovieSearchViewModel: MovieSearchViewModelProvider {
    
    var numberOfItems: Int { movies.count }
    
    func movieItem(atIndexPath indexPath: IndexPath) -> MovieItemViewModel {
        let movie = movies[indexPath.row]
        
        let posterImage = getImageOrLoad(atIndexPath: indexPath, movie: movie)
        
        return .init(posterImage: posterImage,
                     title: movie.title,
                     overview: movie.overview,
                     vote: "\(movie.voteAverage)",
                     releaseDate: movie.releaseDate.flatMap(dateFormatter.string(from:)))
    }
    
    func movieID(atIndexPath indexPath: IndexPath) -> Int64 {
        movies[indexPath.row].id
    }
}
