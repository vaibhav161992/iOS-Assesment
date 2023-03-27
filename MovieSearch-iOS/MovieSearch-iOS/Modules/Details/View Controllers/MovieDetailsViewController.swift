//
//  MovieDetailsViewController.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    
    @IBOutlet private weak var backdropImageView: UIImageView!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var voteLabel: UILabel!
    
    @IBOutlet private weak var overviewLabel: UILabel!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    @IBOutlet private weak var revenueLabel: UILabel!
    @IBOutlet private weak var runtimeLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var taglineLabel: UILabel!
    
    var viewModel: MovieDetailsViewModelProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.delegate = self
        viewModel?.loadDetails()
    }
}

extension MovieDetailsViewController: MovieDetailsViewModelDelegate {
    func reloadData() {
        if let backdropImage = viewModel?.backdropImage {
            backdropImageView.image = backdropImage
            backdropImageView.isHidden = false
        }
        if let posterImage = viewModel?.posterImage {
            posterImageView.image = posterImage
        }
        if let title = viewModel?.title {
            self.title = viewModel?.title
            titleLabel.text = title
        }
        if let vote = viewModel?.vote {
            voteLabel.text = vote
        }
        if let overview = viewModel?.overview {
            overviewLabel.text = overview
            overviewLabel.isHidden = false
        }
        if let releaseDate = viewModel?.releaseDate {
            releaseDateLabel.text = releaseDate
            releaseDateLabel.isHidden = false
        }
        if let revenue = viewModel?.revenue {
            revenueLabel.text = revenue
            revenueLabel.isHidden = false
        }
        if let runtime = viewModel?.runtime {
            runtimeLabel.text = runtime
            runtimeLabel.isHidden = false
        }
        if let status = viewModel?.status {
            statusLabel.text = status
            statusLabel.isHidden = false
        }
        if let tagline = viewModel?.tagline {
            taglineLabel.text = tagline
            taglineLabel.isHidden = false
        }
    }
}
