//
//  PokemonDetailConfigurator.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

final class PokemonDetailConfigurator {
    static func configure(dependencyContainer: DependencyContainer, pokemonId: Int) -> PokemonDetailViewController {
        let router = PokemonDetailRouter()
        let interactor = PokemonDetailInteractor(getPokemonDetailUseCase: dependencyContainer.getPokemonDetailUseCase)
        let presenter = PokemonDetailPresenter(interactor: interactor, router: router, pokemonId: pokemonId)
        let viewController = PokemonDetailViewController(presenter: presenter)
        
        // Connect outputs
        presenter.output = viewController
        interactor.output = presenter
        router.viewController = viewController
        
        return viewController
    }
}

