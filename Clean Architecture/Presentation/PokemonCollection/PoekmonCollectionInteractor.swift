//
//  PoekmonCollectionInteractor.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

protocol PokemonCollectionInteractorInput {
    func fetchPokemonList(offset: Int, limit: Int)
    func loadMorePokemon(offset: Int, limit: Int)
    func searchPokemon(name: String)
}

protocol PokemonCollectionInteractorOutput: AnyObject {
    func didFetchPokemonList(_ pokemons: [Pokemon])
    func didFailFetchingPokemonList(_ error: Error)
    func didLoadMorePokemon(_ pokemons: [Pokemon])
    func didSearchPokemon(_ pokemon: Pokemon?)
}

final class PokemonCollectionInteractor: PokemonCollectionInteractorInput {
    weak var output: PokemonCollectionInteractorOutput?
    private let getPokemonListUseCase: GetPokemonListUseCase
    private let searchPokemonUseCase: SearchPokemonUseCase
    
    init(getPokemonListUseCase: GetPokemonListUseCase, searchPokemonUseCase: SearchPokemonUseCase) {
        self.getPokemonListUseCase = getPokemonListUseCase
        self.searchPokemonUseCase = searchPokemonUseCase
    }
    
    func fetchPokemonList(offset: Int, limit: Int) {
        getPokemonListUseCase.execute(offset: offset, limit: limit) { [weak self] result in
            switch result {
            case .success(let pokemons):
                self?.output?.didFetchPokemonList(pokemons)
            case .failure(let error):
                self?.output?.didFailFetchingPokemonList(error)
            }
        }
    }
    
    func loadMorePokemon(offset: Int, limit: Int) {
        getPokemonListUseCase.execute(offset: offset, limit: limit) { [weak self] result in
            switch result {
            case .success(let pokemons):
                self?.output?.didLoadMorePokemon(pokemons)
            case .failure(let error):
                self?.output?.didFailFetchingPokemonList(error)
            }
        }
    }
    
    func searchPokemon(name: String) {
        guard !name.isEmpty else {
            self.output?.didSearchPokemon(nil)
            return
        }
        
        searchPokemonUseCase.execute(name: name) { [weak self] result in
            switch result {
            case .success(let pokemon):
                self?.output?.didSearchPokemon(pokemon)
            case .failure:
                self?.output?.didSearchPokemon(nil)
            }
        }
    }
}

