import Foundation
import Alamofire

protocol NetworkServiceProtocol {
    func request<T: Decodable, E: APIEndpoint>(_ endpoint: E, completion: @escaping (Result<T, NetworkError>) -> Void)
    @available(iOS 15.0, *)
    func request<T: Decodable, E: APIEndpoint>(_ endpoint: E) async -> Result<T, NetworkError>
}

protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var headers: HTTPHeaders? { get }
    var encoding: ParameterEncoding { get }
    var multipartFormData: ((MultipartFormData) -> Void)? { get }
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case networkError(Error)
}

class NetworkRouter: NetworkServiceProtocol {
    static let shared = NetworkRouter()
    
    private let session: Session
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        session = Session(configuration: configuration)
    }
    
    // MARK: - NetworkServiceProtocol Implementation
    func request<T: Decodable, E: APIEndpoint>(_ endpoint: E, completion: @escaping (Result<T, NetworkError>) -> Void) {
        let url = endpoint.baseURL + endpoint.path
        
        if endpoint.multipartFormData != nil {
            performMultipartRequest(url: url, endpoint: endpoint, completion: completion)
        } else {
            performStandardRequest(url: url, endpoint: endpoint, completion: completion)
        }
    }
    
    @available(iOS 15.0, *)
    func request<T: Decodable, E: APIEndpoint>(_ endpoint: E) async -> Result<T, NetworkError> {
        return await withCheckedContinuation { continuation in
            request(endpoint) { (result: Result<T, NetworkError>) in
                continuation.resume(returning: result)
            }
        }
    }
    
    private func performStandardRequest<T: Decodable, E: APIEndpoint>(url: String, endpoint: E, completion: @escaping (Result<T, NetworkError>) -> Void) {
        session.request(url,
                       method: endpoint.method,
                       parameters: endpoint.parameters,
                       encoding: endpoint.encoding,
                       headers: endpoint.headers)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    completion(.success(value))
                case .failure(let error):
                    completion(.failure(.networkError(error)))
                }
            }
    }
    
    private func performMultipartRequest<T: Decodable, E: APIEndpoint>(url: String, endpoint: E, completion: @escaping (Result<T, NetworkError>) -> Void) {
        session.upload(multipartFormData: { multipartFormData in
            endpoint.multipartFormData?(multipartFormData)
        }, to: url, method: endpoint.method, headers: endpoint.headers)
        .validate()
        .responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
    }
}