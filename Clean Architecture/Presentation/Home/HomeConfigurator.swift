//
//  HomeConfigurator.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

final class HomeConfigurator {
    static func configure(dependencyContainer: DependencyContainer) -> HomeViewController {
        let router = HomeRouter(dependencyContainer: dependencyContainer)
        let interactor = HomeInteractor(getRandomPokemonUseCase: dependencyContainer.getRandomPokemonUseCase)
        let presenter = HomePresenter(interactor: interactor, router: router)
        
        let viewController = HomeViewController(presenter: presenter)
        
        // Connect outputs
        presenter.output = viewController
        interactor.output = presenter
        router.viewController = viewController
        
        return viewController
    }
}

