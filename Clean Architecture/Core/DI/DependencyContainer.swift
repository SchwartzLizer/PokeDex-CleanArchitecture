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
    let getRandomPokemonUseCase: GetRandomPokemonUseCase
    private let getPokemonListUseCase: GetPokemonListUseCase
    private let getPokemonDetailUseCase: GetPokemonDetailUseCase
    private lazy var searchPokemonUseCase: SearchPokemonUseCase = {
        return SearchPokemonUseCaseImpl(repository: pokemonRepository)
    }()
    
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
        return HomeConfigurator.configure(dependencyContainer: self)
    }
    
    func makePokemonCollectionViewController() -> PokemonCollectionViewController {
        let viewModel = PokemonCollectionViewModel(
            getPokemonListUseCase: getPokemonListUseCase,
            searchPokemonUseCase: searchPokemonUseCase
        )
        return PokemonCollectionViewController(viewModel: viewModel)
    }
    
}
