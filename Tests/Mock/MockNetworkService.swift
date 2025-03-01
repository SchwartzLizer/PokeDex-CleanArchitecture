//
//  MockNetworkService.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import Foundation
import Alamofire

@testable import Clean_Architecture

final class MockNetworkService: NetworkServiceProtocol {
    
    var mockResult: Result<Any, NetworkError>?
    var invokedEndpoint: APIEndpoint?
    var invokedCount = 0
    
    func request<T: Decodable, E: APIEndpoint>(_ endpoint: E, completion: @escaping (Result<T, NetworkError>) -> Void) {
        invokedEndpoint = endpoint
        invokedCount += 1
        
        guard let mockResult = mockResult else {
            completion(.failure(.networkError(NSError(domain: "No mock result set", code: 0))))
            return
        }
        
        switch mockResult {
        case .success(let data):
            if let typedData = data as? T {
                completion(.success(typedData))
            } else {
                completion(.failure(.decodingError))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    @available(iOS 15.0, *)
    func request<T: Decodable, E: APIEndpoint>(_ endpoint: E) async -> Result<T, NetworkError> {
        invokedEndpoint = endpoint
        invokedCount += 1
        
        guard let mockResult = mockResult else {
            return .failure(.networkError(NSError(domain: "No mock result set", code: 0)))
        }
        
        switch mockResult {
        case .success(let data):
            if let typedData = data as? T {
                return .success(typedData)
            } else {
                return .failure(.decodingError)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // Helper methods to set up test data
    func setSuccessResult<T: Decodable>(_ data: T) {
        mockResult = .success(data)
    }
    
    func setErrorResult(_ error: NetworkError) {
        mockResult = .failure(error)
    }
    
    func reset() {
        mockResult = nil
        invokedEndpoint = nil
        invokedCount = 0
    }
}
