import Foundation
//
//  HomeInteractor.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

protocol HomeInteractorInput {
    func fetchRandomPokemon()
}

protocol HomeInteractorOutput: AnyObject {
    func didFetchRandomPokemon(_ pokemon: Pokemon)
    func didFailFetchingRandomPokemon(_ error: Error)
}

final class HomeInteractor: HomeInteractorInput {
    private let getRandomPokemonUseCase: GetRandomPokemonUseCase
    weak var output: HomeInteractorOutput?
    
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

