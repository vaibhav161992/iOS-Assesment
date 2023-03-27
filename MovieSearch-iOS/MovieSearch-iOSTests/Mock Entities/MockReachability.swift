//
//  MockReachability.swift
//  MovieSearch-iOSTests
//
//  Created by Vaibhav Gajjar on 27/03/23.
//

@testable import MovieSearch_iOS

class MockReachability: NetworkReachabilityProvider {
    var isNetworkReachable: Bool = false
}
