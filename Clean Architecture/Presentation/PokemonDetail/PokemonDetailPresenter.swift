//
//  PokemonDetailPresenter.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

protocol PokemonDetailPresenterInput {
    func viewDidLoad()
}

protocol PokemonDetailPresenterOutput: AnyObject {
    func updateState(_ state: PokemonDetailViewState)
}

final class PokemonDetailPresenter: PokemonDetailPresenterInput {
    weak var output: PokemonDetailPresenterOutput?
    private let interactor: PokemonDetailInteractorInput
    private let router: PokemonDetailRouting
    private let pokemonId: Int
    private var pokemon: PokemonDetail?
    
    init(interactor: PokemonDetailInteractorInput, router: PokemonDetailRouting, pokemonId: Int) {
        self.interactor = interactor
        self.router = router
        self.pokemonId = pokemonId
    }
    
    func viewDidLoad() {
        output?.updateState(.loading)
        interactor.fetchPokemonDetail(id: pokemonId)
    }
}

extension PokemonDetailPresenter: PokemonDetailInteractorOutput {
    func didFetchPokemonDetail(_ pokemon: PokemonDetail) {
        self.pokemon = pokemon
        output?.updateState(.loaded(pokemon))
    }
    
    func didFailFetchingPokemonDetail(_ error: Error) {
        output?.updateState(.error(error))
    }
}

