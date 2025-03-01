import Foundation
import Alamofire

enum PokemonRouter: APIEndpoint {
    case fetchPokemonList(offset: Int, limit: Int)
    case fetchPokemonDetail(id: Int)
    
    var baseURL: String {
        return "https://pokeapi.co/api/v2"
    }
    
    var path: String {
        switch self {
        case .fetchPokemonList:
            return "/pokemon"
        case .fetchPokemonDetail(let id):
            return "/pokemon/\(id)"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchPokemonList(let offset, let limit):
            return ["offset": offset, "limit": limit]
        case .fetchPokemonDetail:
            return nil
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        return nil
    }
}