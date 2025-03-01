//
//  Router.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 2/28/25.
//

import Foundation
import Alamofire

enum PokemonEndpoint: APIEndpoint {
    case getList(litmit: Int, offset: Int)
    case getDetail(id: Int)
    case getRandom(randomId: Int)
    case getSearchedPokemon(name: String)
    
    var baseURL: String {
        return "https://pokeapi.co/api/v2/"
    }
    
    var path: String {
        switch self {
        case .getList (let limit, let offset):
            return "pokemon?limit=\(limit)&offset=\(offset)"
        case .getDetail(id: let id):
            return "pokemon/\(id)"
        case .getRandom(randomId: let randomId):
            return "pokemon/\(randomId)"
        case .getSearchedPokemon(name: let name):
            return "pokemon/\(name)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        default: return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        default: return nil
        }
    }
    
    var headers: HTTPHeaders? {
        return [
            HTTPHeaderField.contentType.rawValue: ContentType.json.rawValue,
            HTTPHeaderField.acceptType.rawValue: ContentType.json.rawValue,
        ]
    }
    
    var encoding: ParameterEncoding {
        switch self {
        default: return JSONEncoding.default
        }
    }
    
    var multipartFormData: ((MultipartFormData) -> Void)? {
        switch self {
        default:
            return nil
        }
    }
}
