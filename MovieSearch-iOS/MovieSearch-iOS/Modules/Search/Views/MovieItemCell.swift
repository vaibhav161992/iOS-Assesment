//
//  MovieItemCell.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import UIKit

/// A cell representing single movie item in table.
class MovieItemCell: UITableViewCell {
    
    static var reuseIdentifier: String { String(describing: Self.self) }
    
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var voteLabel: UILabel!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    
    /// Configures the cell with given view model.
    /// - Parameter viewModel: A `MovieItemViewModel` object.
    func configure(with viewModel: MovieItemViewModel) {
        posterImageView.image = viewModel.posterImage
        titleLabel.text = viewModel.title
        voteLabel.text = viewModel.vote
        releaseDateLabel.text = viewModel.releaseDate
    }
}
