//
//  MovieItemViewModel.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import UIKit

/// A view model for the movie item in the cell.
struct MovieItemViewModel {
    
    var posterImage: UIImage?
    var title: String?
    var vote: String?
    var releaseDate: String?
    
    init(posterImage: UIImage? = nil, title: String? = nil, overview: String? = nil, vote: String? = nil, releaseDate: String? = nil) {
        self.posterImage = posterImage
        self.title = title
        self.vote = vote.flatMap({ $0.isEmpty ? "Ratings not available" : "\($0)/10"})
        self.releaseDate = releaseDate.flatMap({ $0.isEmpty ? "Release date not available" : "Released on \($0)"})
    }
}
