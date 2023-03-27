//
//  Movie.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import Foundation

struct Movie: Decodable {
    let id: Int
    let posterPath: String?
    let overview: String?
    let releaseDate: String?
    let title: String?
    let backdropPath: String?
    let popularity: Double?
    let voteCount: Int?
    let voteAverage: Double?

    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case overview = "overview"
        case releaseDate = "release_date"
        case id = "id"
        case title = "title"
        case backdropPath = "backdrop_path"
        case popularity = "popularity"
        case voteCount = "vote_count"
        case voteAverage = "vote_average"
    }
}
