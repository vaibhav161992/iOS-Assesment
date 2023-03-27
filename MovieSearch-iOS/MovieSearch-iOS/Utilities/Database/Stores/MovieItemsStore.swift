//
//  MovieItemRepository.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 27/03/23.
//

import CoreData

protocol MovieItemCacheProvider {
    func searchMovies(withQuery query: String,
                      completion: @escaping ([MovieItem]?) -> Void)
    func movieItem(fromMovie movie: Movie) -> MovieItem?
    func movieItem(fromMovieDetails movieDetails: MovieDetails) -> MovieItem?
    func fetchMovie(withID id: Int) throws -> MovieItem
}

class MovieItemsStore: MovieItemCacheProvider {
    
    private let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
    
    let repository: DataRepositoryProvider
    
    init(repository: DataRepositoryProvider = DataRepository.shared) {
        self.repository = repository
    }
    
    func searchMovies(withQuery query: String,
                      completion: @escaping ([MovieItem]?) -> Void) {
        let fetchRequest = MovieItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title CONTAINS[c] %@", query as NSString)
        do {
            let movieItems = try repository.viewContext.fetch(fetchRequest)
            completion(movieItems)
        } catch {
            assertionFailure("Error performing database operation: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    func movieItem(fromMovie movie: Movie) -> MovieItem? {
        do {
            var movieItem = try fetchMovie(withID: movie.id)
            self.update(movieItem: &movieItem, withMovie: movie)
            try self.repository.viewContext.save()
            return movieItem
        } catch {
            assertionFailure("Error performing database operation: \(error.localizedDescription)")
            return nil
        }
    }
    
    func movieItem(fromMovieDetails movieDetails: MovieDetails) -> MovieItem? {
        do {
            var movieItem = try fetchMovie(withID: movieDetails.id)
            self.update(movieItem: &movieItem, withDetails: movieDetails)
            try self.repository.viewContext.save()
            return movieItem
        } catch {
            assertionFailure("Error performing database operation: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchMovie(withID id: Int) throws -> MovieItem {
        let fetchRequest = MovieItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", NSNumber(integerLiteral: id))
        let movieItems = try repository.viewContext.fetch(fetchRequest)
        if let movie = movieItems.first {
            return movie
        } else {
            var newItem = MovieItem(context: repository.viewContext)
            try self.repository.viewContext.save()
            return newItem
        }
    }
    
    private func update(movieItem: inout MovieItem, withMovie movie: Movie) {
        movieItem.id = Int64(movie.id)
        movieItem.posterPath = movie.posterPath
        movieItem.overview = movie.overview
        movieItem.releaseDate = movie.releaseDate.flatMap(dateFormatter.date(from:))
        movieItem.title = movie.title
        movieItem.backdropPath = movie.backdropPath
        movieItem.popularity = movie.popularity ?? 0.0
        movieItem.voteCount = Int64(movie.voteCount ?? 0)
        movieItem.voteAverage = movie.voteAverage ?? 0.0
    }
    
    private func update(movieItem: inout MovieItem, withDetails details: MovieDetails) {
        movieItem.id = Int64(details.id)
        movieItem.backdropPath = details.backdropPath
        movieItem.genres = details.genres.map(\.name).joined(separator: ", ")
        movieItem.overview = details.overview
        movieItem.popularity = details.popularity
        movieItem.posterPath = details.posterPath
        movieItem.releaseDate = dateFormatter.date(from: details.releaseDate)
        movieItem.revenue = Int64(details.revenue)
        movieItem.runtime = Int64(details.runtime ?? 0)
        movieItem.status = details.status
        movieItem.tagline = details.tagline
        movieItem.title = details.title
        movieItem.voteAverage = details.voteAverage
        movieItem.voteCount = Int64(details.voteCount)
    }
}
