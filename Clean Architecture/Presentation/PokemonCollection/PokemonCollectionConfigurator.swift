//
//  PokemonCollectionConfigurator.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

final class PokemonCollectionConfigurator {
    static func configure(dependencyContainer: DependencyContainer) -> PokemonCollectionViewController {
        let router = PokemonCollectionRouter(dependencyContainer: dependencyContainer)
        let interactor = PokemonCollectionInteractor(
            getPokemonListUseCase: dependencyContainer.getPokemonListUseCase,
            searchPokemonUseCase: dependencyContainer.searchPokemonUseCase
        )
        let presenter = PokemonCollectionPresenter(interactor: interactor, router: router)
        let viewController = PokemonCollectionViewController(presenter: presenter)
        
        // Connect outputs
        presenter.output = viewController
        interactor.output = presenter
        router.viewController = viewController
        
        return viewController
    }
}

