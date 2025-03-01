//
//  HomePresenter.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

protocol HomePresenterInput {
    func presentRandomPokemon()
    func presentPokemonCollection()
}

protocol HomePresenterOutput: AnyObject {
    func updateState(_ state: HomeViewState)
}

final class HomePresenter: HomePresenterInput {
    private let interactor: HomeInteractorInput
    private let router: HomeRouting
    weak var output: HomePresenterOutput?
    
    init(interactor: HomeInteractorInput, router: HomeRouting) {
        self.interactor = interactor
        self.router = router
    }
    
    func presentRandomPokemon() {
        output?.updateState(.loading)
        interactor.fetchRandomPokemon()
    }
    
    func presentPokemonCollection() {
        router.navigateToPokemonCollection()
    }
}

extension HomePresenter: HomeInteractorOutput {
    func didFetchRandomPokemon(_ pokemon: Pokemon) {
        let model = HomeModel(pokemon: pokemon)
        output?.updateState(.loaded(model))
    }
    
    func didFailFetchingRandomPokemon(_ error: Error) {
        output?.updateState(.error(error))
    }
}

