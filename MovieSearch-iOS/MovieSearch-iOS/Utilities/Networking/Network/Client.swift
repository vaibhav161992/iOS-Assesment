//
//  Client.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import Foundation

extension ServiceFetcher {
    /// A Client to which a service will connect.
    struct Client {
        let scheme: String
        let host: String
    }
}
