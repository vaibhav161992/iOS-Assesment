//
//  MockServiceFetcher.swift
//  MovieSearch-iOSTests
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import Foundation
@testable import MovieSearch_iOS

class MockServiceFetcher: ServiceFetchingProvider {
    
    class MockTask: ServiceTask {
        var isCancelled: Bool = false
        var url: URL
        
        init(url: URL) {
            self.url = url
        }
        
        func cancel() {
            isCancelled = true
        }
    }
    
    private var mockData: [String: Data] = [:]
    var tasks: [MockTask] = []
    
    func setup(data: Data, forEndpoint endpoint: EndpointProvider) {
        guard let url = try? endpoint.getEndpoint().createURL() else { return }
        
        self.mockData[url.absoluteString] = data
    }
    
    func setup(jsonFile: String, forEndpoint endpoint: EndpointProvider) {
        let data = MockDataProvider.getMockData(fromFile: jsonFile)
        setup(data: data, forEndpoint: endpoint)
    }
    
    func removeMockData() {
        self.mockData = [:]
        self.tasks = []
    }
    
    func request
    <Response, Endpoint>(
        _ endpoint: Endpoint,
        forType type: Response.Type,
        then handler: @escaping (MockServiceFetcher.Result<Response>) -> Void
    ) -> ServiceTask? where Response : Decodable, Endpoint : EndpointProvider {
        let endpoint = endpoint.getEndpoint()
        guard let url = try? endpoint.createURL() else {
            handler(.failure(.invalidURL(url: "\(endpoint)")))
            return nil
        }

        let handlerOnMain: (MockServiceFetcher.Result<Response>) -> Void = { result in
            DispatchQueue.main.async {
                handler(result)
            }
        }
        let task = MockTask(url: url)
        tasks.append(task)
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .seconds(1)) {
            
            self.handleReponseData(self.mockData[url.absoluteString],
                                   nil,
                                   forType: type,
                                   completionHandler: handlerOnMain)
        }
        return task
    }
}
