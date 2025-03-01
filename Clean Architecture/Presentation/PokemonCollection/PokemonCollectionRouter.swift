//
//  PokemonCollectionRouter.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import UIKit

protocol PokemonCollectionRouting {
    func navigateToDetail(pokemonId: Int)
}

final class PokemonCollectionRouter: PokemonCollectionRouting {
    weak var viewController: UIViewController?
    private let dependencyContainer: DependencyContainer
    
    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
    }
    
    func navigateToDetail(pokemonId: Int) {
        let detailViewModel = PokemonDetailViewModel(getPokemonDetailUseCase: GetPokemonDetailUseCaseImpl(repository: PokemonRepositoryImpl(networkService: NetworkService())))
        let detailViewController = PokemonDetailViewController(viewModel: detailViewModel, pokemonId: pokemonId)
        viewController?.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

