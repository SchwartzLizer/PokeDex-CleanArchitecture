//
//  HomeViewModel.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import Foundation

protocol HomeViewModelInput {
    func fetchRandomPokemon()
}

protocol HomeViewModelOutput: AnyObject {
    func didFetchRandomPokemon(_ pokemon: Pokemon)
    func didFailFetchingRandomPokemon(_ error: Error)
}

final class HomeViewModel: HomeViewModelInput {
    weak var output: HomeViewModelOutput?
    private let getRandomPokemonUseCase: GetRandomPokemonUseCase
    
    init(getRandomPokemonUseCase: GetRandomPokemonUseCase) {
        self.getRandomPokemonUseCase = getRandomPokemonUseCase
    }
    
    func fetchRandomPokemon() {
        getRandomPokemonUseCase.execute { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let pokemon):
                    self.output?.didFetchRandomPokemon(pokemon)
                case .failure(let error):
                    self.output?.didFailFetchingRandomPokemon(error)
                }
            }
        }
    }
}
