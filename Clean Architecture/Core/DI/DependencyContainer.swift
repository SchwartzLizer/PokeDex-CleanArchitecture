//
//  DependencyContainer.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import Foundation

final class DependencyContainer {
    // Singletons
    private let networkService: NetworkServiceProtocol
    private let pokemonRepository: PokemonRepository
    
    // Use cases
    private let getPokemonListUseCase: GetPokemonListUseCase
    private let getPokemonDetailUseCase: GetPokemonDetailUseCase
    private let getRandomPokemonUseCase: GetRandomPokemonUseCase
    
    init() {
        // Initialize dependencies
        self.networkService = NetworkService()
        self.pokemonRepository = PokemonRepositoryImpl(networkService: networkService)
        
        // Initialize use cases
        self.getPokemonListUseCase = GetPokemonListUseCaseImpl(repository: pokemonRepository)
        self.getPokemonDetailUseCase = GetPokemonDetailUseCaseImpl(repository: pokemonRepository)
        self.getRandomPokemonUseCase = GetRandomPokemonUseCaseImpl(repository: pokemonRepository)
    }
    
    // Factory methods for view controllers
    func makeHomeViewController(router: HomeRouting) -> HomeViewController {
        let viewModel = HomeViewModel(getRandomPokemonUseCase: getRandomPokemonUseCase)
        return HomeViewController(viewModel: viewModel, router: router)
    }
    
    func makePokemonCollectionViewController() -> PokemonCollectionViewController {
        let viewModel = PokemonCollectionViewModel(getPokemonListUseCase: getPokemonListUseCase)
        return PokemonCollectionViewController(viewModel: viewModel)
    }
}
