//
//  PokemonDetailInteractor.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import Foundation

protocol PokemonDetailInteractorInput {
    func fetchPokemonDetail(id: Int)
}

protocol PokemonDetailInteractorOutput: AnyObject {
    func didFetchPokemonDetail(_ pokemon: PokemonDetail)
    func didFailFetchingPokemonDetail(_ error: Error)
}

final class PokemonDetailInteractor: PokemonDetailInteractorInput {
    weak var output: PokemonDetailInteractorOutput?
    private let getPokemonDetailUseCase: GetPokemonDetailUseCase
    
    init(getPokemonDetailUseCase: GetPokemonDetailUseCase) {
        self.getPokemonDetailUseCase = getPokemonDetailUseCase
    }
    
    func fetchPokemonDetail(id: Int) {
        getPokemonDetailUseCase.execute(id: id) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let pokemonDetail):
                    self.output?.didFetchPokemonDetail(pokemonDetail)
                case .failure(let error):
                    self.output?.didFailFetchingPokemonDetail(error)
                }
            }
        }
    }
}

