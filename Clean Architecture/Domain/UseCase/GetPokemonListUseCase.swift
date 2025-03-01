//
//  GetPokemonListUseCase.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import Foundation

protocol GetPokemonListUseCase {
    func execute(offset: Int, limit: Int, completion: @escaping (Result<[Pokemon], Error>) -> Void)
}

final class GetPokemonListUseCaseImpl: GetPokemonListUseCase {
    private let repository: PokemonRepository
    
    init(repository: PokemonRepository) {
        self.repository = repository
    }
    
    func execute(offset: Int, limit: Int, completion: @escaping (Result<[Pokemon], Error>) -> Void) {
        repository.getPokemonList(offset: offset, limit: limit, completion: completion)
    }
}
