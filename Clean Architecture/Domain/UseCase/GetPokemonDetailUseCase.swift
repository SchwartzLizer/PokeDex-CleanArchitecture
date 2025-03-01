//
//  GetPokemonDetailUseCase.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import Foundation

protocol GetPokemonDetailUseCase {
    func execute(id: Int, completion: @escaping (Result<PokemonDetail, Error>) -> Void)
}

final class GetPokemonDetailUseCaseImpl: GetPokemonDetailUseCase {
    private let repository: PokemonRepository
    
    init(repository: PokemonRepository) {
        self.repository = repository
    }
    
    func execute(id: Int, completion: @escaping (Result<PokemonDetail, Error>) -> Void) {
        repository.getPokemonDetail(id: id, completion: completion)
    }
}
