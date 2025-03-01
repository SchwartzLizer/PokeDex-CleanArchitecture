//
//  HomeRouter.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import UIKit

protocol HomeRouting {
    func navigateToPokemonCollection()
}

final class HomeRouter: HomeRouting {
    weak var viewController: UIViewController?
    private let dependencyContainer: DependencyContainer
    
    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
    }
    
    func navigateToPokemonCollection() {
        let pokemonCollectionVC = dependencyContainer.makePokemonCollectionViewController()
        viewController?.navigationController?.pushViewController(pokemonCollectionVC, animated: true)
    }
}
