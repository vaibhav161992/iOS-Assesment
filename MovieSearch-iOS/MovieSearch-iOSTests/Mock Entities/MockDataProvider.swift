//
//  MockDataProvider.swift
//  MovieSearch-iOSTests
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import Foundation

enum MockDataProvider {
    
    static func getMockData(fromFile: String, ofType type: String = "json") -> Data {
        do {
            if let bundlePath = Bundle.main.path(forResource: "MockResources", ofType: "bundle"),
                let bundle = Bundle(path: bundlePath),
                let path = bundle.path(forResource: fromFile, ofType: type) {
                let url = URL(fileURLWithPath: path)
                let data = try Data(contentsOf: url, options: .mappedIfSafe)
                return data
            }
        } catch {
            print("\(error.localizedDescription)")
            fatalError("Unable to find a file mock file with name \(fromFile).json .")
        }
        
        fatalError("Unable to find a file mock file with name \(fromFile).json .")
    }
}
