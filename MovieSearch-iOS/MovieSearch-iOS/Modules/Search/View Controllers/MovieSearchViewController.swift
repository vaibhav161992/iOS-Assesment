//
//  MovieSearchViewController.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 23/03/23.
//

import UIKit

/// Main view controller in the app.
class MovieSearchViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 270
            tableView.rowHeight = UITableView.automaticDimension
        }
    }
    @IBOutlet private var noResultsView: UIView!
    @IBOutlet private weak var noResultsLabel: UILabel!
    
    // MARK: - Properties
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        return searchController
    }()
    
    private let viewModel: MovieSearchViewModelProvider = MovieSearchViewModel()
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Search TMDb"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Clear image cache if we receive a memory warning.
        ImageCache.shared.clear()
    }
    
    // MARK: - Private Methods
    private func configureNoResultsView() {
        // We can definitely implement localisation to support multiple languages. Skipping for now.
        self.noResultsLabel.text = (viewModel.searchText?.isEmpty ?? true) ? "Please type something to explore the movies." : "Oops!, there are no results for \"\(viewModel.searchText ?? "")\", try something else."
    }
    
    private func navigateToMovieDetails(for movieID: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let detailsController = storyboard.instantiateViewController(withIdentifier: "MovieDetailsViewController") as? MovieDetailsViewController else {
            fatalError("Unable to instantiate view controller with identifier 'MovieDetailsViewController'")
        }
        guard let viewModel = MovieDetailsViewModel(movieID: movieID) else {
            assertionFailure("Unable to create detail view model.")
            return
        }
        detailsController.viewModel = viewModel
        navigationController?.show(detailsController, sender: self)
    }
}

// MARK: - UITableViewDataSource
extension MovieSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Can implement some protocol based generic methods for dequeueing the cell, But since we only have once cell, Skipped it.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieItemCell.reuseIdentifier,
                                                       for: indexPath) as? MovieItemCell else {
            fatalError("Unable to dequeue reusable cell for identifier \"\(MovieItemCell.reuseIdentifier)\"")
        }
        cell.configure(with: viewModel.movieItem(atIndexPath: indexPath))
        return cell
    }
}

extension MovieSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard viewModel.numberOfItems > indexPath.row else { return }
        self.navigateToMovieDetails(for: Int(viewModel.movieID(atIndexPath: indexPath)))
    }
}

// MARK: - UISearchResultsUpdating
extension MovieSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Changing this search text invokes all the logic in view model.
        viewModel.searchText = searchController.searchBar.text
    }
}

// MARK: - MovieSearchViewModelDelegate
extension MovieSearchViewController: MovieSearchViewModelDelegate {
    func reloadData() {
        // Set some good message for blank screen, nobody likes to see an empty screen.
        if viewModel.numberOfItems == 0 {
            configureNoResultsView()
            tableView.backgroundView = noResultsView
        } else {
            tableView.backgroundView = nil
        }
        tableView.reloadData()
    }
    
    func reloadItem(atIndexPath indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
