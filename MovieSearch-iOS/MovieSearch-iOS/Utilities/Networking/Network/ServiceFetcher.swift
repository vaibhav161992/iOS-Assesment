//
//  ServiceFetcher.swift
//  MovieSearch-iOS
//
//  Created by Vaibhav Gajjar on 24/03/23.
//

import Foundation

protocol ServiceTask {

    func cancel()
}

extension URLSessionDataTask: ServiceTask {}

protocol ServiceFetchingProvider {
    @discardableResult func request
    <Response: Decodable,
     Endpoint: EndpointProvider>(
        _ endpoint: Endpoint,
        forType type: Response.Type,
        then handler: @escaping (Result<Response>) -> Void
    ) -> ServiceTask?
}

/// A class responsible for making web request.
struct ServiceFetcher: ServiceFetchingProvider {
    
    let session: URLSession
    
    /// Requests an endpoint and invokes handler on completion.
    /// - Parameters:
    ///   - endpoint: An entity confoming to `EndpointProvider`.
    ///   - type: A type conforming to `Decodable`.
    ///   - handler: A completion handler which will be invoked with `Result`.
    @discardableResult func request
    <Response: Decodable,
     Endpoint: EndpointProvider>(
        _ endpoint: Endpoint,
        forType type: Response.Type,
        then handler: @escaping (ServiceFetcher.Result<Response>) -> Void
    ) -> ServiceTask? {
        let completionOnMain: (ServiceFetcher.Result<Response>) -> Void = { result in
            DispatchQueue.main.async {
                handler(result)
            }
        }
        do {
            let urlRequest = try endpoint.getEndpoint().urlRequest()
            let task = self.dataTask(with: urlRequest,
                                     forType: Response.self) { result in
                completionOnMain(result)
            }
            task.resume()
            return task
        } catch {
            completionOnMain(.failure((error as? ServiceFetcher.Error) ?? .otherError(error)))
            return nil
        }
    }
    
    private func dataTask
    <Response: Decodable>(
        with urlRequest: URLRequest,
        forType type: Response.Type,
        completionHandler: @escaping (ServiceFetcher.Result<Response>) -> Void
    ) -> URLSessionDataTask {
        
        session.dataTask(with: urlRequest) { data, response, networkError in
            handleReponseData(data, networkError, forType: type, completionHandler: completionHandler)
        }
    }
}

extension ServiceFetchingProvider {
    func handleReponseData<Response: Decodable>(
        _ data: Data?,
        _ error: Error?,
        forType type: Response.Type,
        completionHandler: @escaping (ServiceFetcher.Result<Response>) -> Void) {
        
        guard let data = data else {
            return completionHandler(.failure(.network(error as NSError?)))
        }
        if type == Data.self {
            completionHandler(.success(data as! Response))
            return
        }
        
        do {
            let decodedData = try JSONDecoder().decode(Response.self, from: data)
            completionHandler(.success(decodedData))
        } catch {
            completionHandler(.failure(.unableToDecode(data: data)))
        }
    }
}
