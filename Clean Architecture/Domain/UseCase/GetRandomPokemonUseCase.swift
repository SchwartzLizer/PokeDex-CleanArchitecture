//
//  Untitled.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import Foundation

protocol GetRandomPokemonUseCase {
    func execute(completion: @escaping (Result<Pokemon, Error>) -> Void)
}

final class GetRandomPokemonUseCaseImpl: GetRandomPokemonUseCase {
    private let repository: PokemonRepository
    
    init(repository: PokemonRepository) {
        self.repository = repository
    }
    
    func execute(completion: @escaping (Result<Pokemon, Error>) -> Void) {
        repository.getRandomPokemon(completion: completion)
    }
}
