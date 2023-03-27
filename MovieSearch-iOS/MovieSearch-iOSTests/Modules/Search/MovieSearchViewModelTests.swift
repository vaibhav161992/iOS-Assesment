//
//  MovieSearchViewModelTests.swift
//  MovieSearch-iOSTests
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import XCTest
@testable import MovieSearch_iOS

class MovieSearchViewModelTests: XCTestCase {
    
    // MARK: - Constants
    private enum Constants {
        
        static let searchTerm = "harry"
        static let posterName = "wuMc08IPKEatf9rnMNXvIDxqP4W"
        static let imageType = "jpg"
        static let posterQuery = "/\(posterName).\(imageType)"
        static let expectationTimeout: TimeInterval = 5
        
        enum Resources {
            static let movieSearchJSON = "movie-search"
        }
        
        enum Data {
            static let title = "Harry Potter and the Philosopher's Stone"
            static let overview = "Harry Potter has lived under the stairs at his aunt and uncle's house his whole life. But on his 11th birthday, he learns he's a powerful wizard -- with a place waiting for him at the Hogwarts School of Witchcraft and Wizardry. As he learns to harness his newfound powers with the help of the school's kindly headmaster, Harry uncovers the truth about his parents' deaths -- and about the villain who's to blame."
            static let releaseDate = "Released on Nov 16, 2001"
            static let vote = "7.9/10"
        }
        
        enum Messages {
            static let shouldCallReload = "Should Call reload data after loading."
            static let shouldCallReloadItem = "Should Call reload item on calling item at index."
            static let unexpectedCall = "reload called without expectation"
            static let allTasksCancelled = "All tasks were cancelled."
        }
    }
    
    // MARK: - Properties
    private let serviceFetcher = MockServiceFetcher()
    private let reachability = MockReachability()
    private var viewModel: MovieSearchViewModel!
    private var viewModelDelegate: MockMovieSearchDelegate?
    private var service: TMDbMovieService!

    // MARK: - Overrides
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Setup all the required objects.
        service = TMDbMovieService(serviceFetcher: serviceFetcher)
        viewModel = MovieSearchViewModel(tmdbService: service, reachability: reachability)
    }

    override func tearDownWithError() throws {
        
        // Clear all the data so the new test will have fresh start.
        viewModel = nil
        service = nil
        serviceFetcher.removeMockData()
        ImageCache.shared.clear()
        try super.tearDownWithError()
    }

    // MARK: - Tests
    /// Checks if the viewModel loads data correctly and calls reload method.
    func testLoadsDataCorrectly_AndCheckFirstItem() throws {
        // Internet is available
        reachability.isNetworkReachable = true
        
        // Setup endpoint and mock data from json file.
        let endpoint = TMDbEndpoint.search(query: Constants.searchTerm)
        self.serviceFetcher.setup(jsonFile: Constants.Resources.movieSearchJSON, forEndpoint: endpoint)
        viewModelDelegate = MockMovieSearchDelegate()
        viewModelDelegate?.reloadDataExpectation = self.expectation(description: Constants.Messages.shouldCallReload)
        
        // Setup callbacks to test the data later.
        viewModelDelegate?.didCallReloadBlock = { [weak self] in
            
            // Check if items are loaded and search term is same.
            XCTAssertEqual(self?.viewModel.numberOfItems, 20)
            XCTAssertEqual(self?.viewModel.searchText, Constants.searchTerm)
            
            // Load the first item.
            let firstItem = self?.viewModel.movieItem(atIndexPath: IndexPath(row: 0, section: 0))
            
            // Check loaded item properties.
            XCTAssertEqual(firstItem?.title, Constants.Data.title)
            XCTAssertEqual(firstItem?.releaseDate, Constants.Data.releaseDate)
            XCTAssertEqual(firstItem?.vote, Constants.Data.vote)
        }
        // Set delegates and search.
        viewModel.delegate = viewModelDelegate
        viewModel.searchText = Constants.searchTerm
        
        waitForExpectations(timeout: Constants.expectationTimeout)
    }
    
    /// Checks if image caching mechanism works as expected.
    func testImageCachingWorks() throws {
        // Internet is available
        reachability.isNetworkReachable = true

        // Setup the mock response from JSON.
        let searchEndpoint = TMDbEndpoint.search(query: Constants.searchTerm)
        self.serviceFetcher.setup(jsonFile: Constants.Resources.movieSearchJSON, forEndpoint: searchEndpoint)
        
        // Setup mock image from bundle image file.
        let posterEndpoint = TMDbEndpoint.poster(posterName: Constants.posterQuery)
        let data = MockDataProvider.getMockData(fromFile: Constants.posterName, ofType: Constants.imageType)
        self.serviceFetcher.setup(data: data, forEndpoint: posterEndpoint)
        
        // Setup delegates and callbacks to check the caching.
        viewModelDelegate = MockMovieSearchDelegate()
        viewModelDelegate?.reloadDataExpectation = self.expectation(description: Constants.Messages.shouldCallReload)
        viewModelDelegate?.reloadItemCalledExpectation = self.expectation(description: Constants.Messages.shouldCallReloadItem)
        viewModelDelegate?.didCallReloadBlock = { [weak self] in
            // Image should be nil initially. and load image should be called.
            let firstItem = self?.viewModel.movieItem(atIndexPath: IndexPath(row: 0, section: 0))
            XCTAssertNil(firstItem?.posterImage)
        }
        
        viewModelDelegate?.didCallReloadItemAtIndex = { [weak self] index in
            // Now, image should be available.
            let firstItem = self?.viewModel.movieItem(atIndexPath: IndexPath(row: 0, section: 0))
            XCTAssertNotNil(firstItem?.posterImage)
        }
        // Set delegates and search.
        viewModel.delegate = viewModelDelegate
        viewModel.searchText = Constants.searchTerm
        
        waitForExpectations(timeout: Constants.expectationTimeout)
    }
    
    /// Checks if the rapid typing cancels previous tasks.
    func testRapidTyping_CancelsPreviousTasks() {
        // Internet is available
        reachability.isNetworkReachable = true

        // Emulate rapid typing.
        viewModel.searchText = "h"
        viewModel.searchText = "ha"
        viewModel.searchText = "har"
        viewModel.searchText = "harr"
        viewModel.searchText = "harry"
        
        // Check the task that was not canceled.
        guard let indexOfNonCanceledTask = serviceFetcher.tasks.firstIndex(where: { $0.isCancelled == false }) else {
            XCTFail(Constants.Messages.allTasksCancelled)
            return
        }
        // Only last task should be not canceled.
        XCTAssertEqual(indexOfNonCanceledTask, 4)
    }
    
    /// Mock Delegate class for checking all the events happening inside of view model.
    private class MockMovieSearchDelegate: MovieSearchViewModelDelegate {
        
        var reloadDataExpectation: XCTestExpectation?
        var reloadItemCalledExpectation: XCTestExpectation?
        
        var didCallReloadBlock: (() -> Void)?
        var didCallReloadItemAtIndex: ((IndexPath) -> Void)?
        
        func reloadData() {
            guard let reloadDataExpectation = reloadDataExpectation else {
                XCTFail(Constants.Messages.unexpectedCall)
                return
            }
            reloadDataExpectation.fulfill()
            didCallReloadBlock?()
        }
        
        func reloadItem(atIndexPath indexPath: IndexPath) {
            guard let reloadItemCalledExpectation = reloadItemCalledExpectation else {
                XCTFail(Constants.Messages.unexpectedCall)
                return
            }
            reloadItemCalledExpectation.fulfill()
            didCallReloadItemAtIndex?(indexPath)
        }
    }
}
