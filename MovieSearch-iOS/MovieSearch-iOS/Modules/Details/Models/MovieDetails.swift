//
//  MovieDetails.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import Foundation

// MARK: - MovieDetails
struct MovieDetails: Decodable {
    let backdropPath: String?
    let genres: [Genre]
    let id: Int //
    let overview: String? //
    let popularity: Double //
    let posterPath: String? //
    let releaseDate: String //
    let revenue: Int //
    let runtime: Int? //
    let status: String //
    let tagline: String? //
    let title: String //
    let voteAverage: Double //
    let voteCount: Int //

    enum CodingKeys: String, CodingKey {
        case backdropPath = "backdrop_path"
        case genres = "genres"
        case id = "id"
        case overview = "overview"
        case popularity = "popularity"
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case revenue = "revenue"
        case runtime = "runtime"
        case status = "status"
        case tagline = "tagline"
        case title = "title"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

// MARK: - Genre
struct Genre: Codable {
    let id: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    }
}
