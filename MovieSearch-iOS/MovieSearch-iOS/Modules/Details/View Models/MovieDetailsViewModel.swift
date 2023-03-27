//
//  MovieDetailsViewModel.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import UIKit

protocol MovieDetailsViewModelDelegate: AnyObject {
    func reloadData()
}

protocol MovieDetailsViewModelProvider {
    
    var delegate: MovieDetailsViewModelDelegate? { get set }
    
    var backdropImage: UIImage? { get }
    var posterImage: UIImage? { get }
    var title: String? { get }
    var vote: String? { get }
    var overview: String? { get }
    var releaseDate: String? { get }
    var revenue: String? { get }
    var runtime: String? { get }
    var status: String? { get }
    var tagline: String? { get }
    
    func loadDetails()
}

class MovieDetailsViewModel: MovieDetailsViewModelProvider {
    
    private let service: TMDbMovieDetailsService
    private let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
    private let revenueFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        return formatter
    }()
    
    private var movie: MovieItem
    weak var delegate: MovieDetailsViewModelDelegate?
    
    init?(movieID: Int, service: TMDbMovieDetailsService = .init()) {
        do {
            let movie = try service.movieCache.fetchMovie(withID: movieID)
            self.movie = movie
            self.service = service
        } catch {
            assertionFailure("Some error occured while performing database operation: \(error)")
            return nil
        }
    }
    
    var backdropImage: UIImage?
    var posterImage: UIImage?
    var title: String? { movie.title }
    var vote: String? {
        "\(movie.voteAverage)/10 [\(movie.voteCount)]"
    }
    var overview: String? { movie.overview }
    var releaseDate: String? {
        movie.releaseDate
        .flatMap {
            "Released on \(dateFormatter.string(from: $0))"
        } ?? "Release date not available"
    }
    
    var revenue: String? {
        revenueFormatter.string(
            from: NSNumber(integerLiteral: Int(movie.revenue))
        )
    }
    var runtime: String? { "\(movie.runtime) minutes" }
    var status: String? { movie.status }
    var tagline: String? { movie.tagline }
    
    func loadDetails() {
        loadPosterImage()
        service.fetchMovieDetails(withID: Int(movie.id)) { movieDetails in
            guard let movieDetails else { return }
            self.movie = movieDetails
            self.loadPosterImage()
            self.delegate?.reloadData()
        }
    }
    
    func loadPosterImage() {
        guard let imagePath = movie.posterPath else { return }
        service.image(forPoster: imagePath) { image in
            self.posterImage = image
            self.delegate?.reloadData()
        }
    }
    
    func loadBackdropImage() {
        guard let imagePath = movie.backdropPath else { return }
        service.image(forPoster: imagePath) { image in
            self.backdropImage = image
            self.delegate?.reloadData()
        }
    }
}
