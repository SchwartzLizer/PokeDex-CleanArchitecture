//
//  PokemonRepository.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

protocol PokemonRepository {
    func getPokemonList(offset: Int, limit: Int, completion: @escaping (Result<[Pokemon], Error>) -> Void)
    func getPokemonDetail(id: Int, completion: @escaping (Result<PokemonDetail, Error>) -> Void)
    func getRandomPokemon(completion: @escaping (Result<Pokemon, Error>) -> Void)
}

final class PokemonRepositoryImpl: PokemonRepository {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getPokemonList(offset: Int, limit: Int, completion: @escaping (Result<[Pokemon], any Error>) -> Void) {
        networkService.request(PokemonEndpoint.getList(litmit: offset, offset: limit)) { (result: Result<PokemonListResponse, NetworkError>) in
            switch result {
            case .success(let response):
                let pokemons = response.results.map { result in
                    // Extract ID from URL
                    let id = Int(result.url.split(separator: "/").last ?? "0") ?? 0
                    return Pokemon(id: id, name: result.name, imageUrl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")
                }
                completion(.success(pokemons))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getPokemonDetail(id: Int, completion: @escaping (Result<PokemonDetail, any Error>) -> Void) {
        networkService.request(PokemonEndpoint.getDetail(id: id)) { (result: Result<PokemonDetailResponse, NetworkError>) in
            switch result {
            case .success(let response):
                let types = response.types.map { $0.type.name }
                let stats = response.stats.map { PokemonStats(name: $0.stat.name, value: $0.baseStat) }
                
                let detail = PokemonDetail(
                    id: response.id,
                    name: response.name.capitalized,
                    height: response.height,
                    weight: response.weight,
                    imageUrl: response.sprites.frontDefault,
                    types: types,
                    stats: stats
                )
                completion(.success(detail))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getRandomPokemon(completion: @escaping (Result<Pokemon, any Error>) -> Void) {
        let randomId = Int.random(in: 1...898)
        
        networkService.request(PokemonEndpoint.getRandom(randomId: randomId)) { (result: Result<PokemonDetailResponse, NetworkError>) in
            switch result {
            case .success(let response):
                let pokemon = Pokemon(
                    id: response.id,
                    name: response.name.capitalized,
                    imageUrl: response.sprites.frontDefault
                )
                completion(.success(pokemon))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
