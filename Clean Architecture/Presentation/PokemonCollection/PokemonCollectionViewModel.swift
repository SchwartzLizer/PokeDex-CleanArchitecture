//
//  PokemonCollectionViewModel.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import Foundation

protocol PokemonCollectionViewModelInput {
    func fetchPokemonList()
    func searchPokemon(with query: String)
    var pokemonList: [Pokemon] { get }
    var filteredPokemonList: [Pokemon] { get }
}

protocol PokemonCollectionViewModelOutput: AnyObject {
    func didFetchPokemonList()
    func didFailFetchingPokemonList(_ error: Error)
    func didUpdateFilteredList()
}

final class PokemonCollectionViewModel: PokemonCollectionViewModelInput {
    weak var output: PokemonCollectionViewModelOutput?
    private let getPokemonListUseCase: GetPokemonListUseCase
    
    private(set) var pokemonList: [Pokemon] = []
    private(set) var filteredPokemonList: [Pokemon] = []
    private var isFiltering = false
    
    init(getPokemonListUseCase: GetPokemonListUseCase) {
        self.getPokemonListUseCase = getPokemonListUseCase
    }
    
    func fetchPokemonList() {
        getPokemonListUseCase.execute(offset: 0, limit: 151) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let pokemons):
                    self.pokemonList = pokemons
                    self.filteredPokemonList = pokemons
                    self.output?.didFetchPokemonList()
                case .failure(let error):
                    self.output?.didFailFetchingPokemonList(error)
                }
            }
        }
    }
    
    func searchPokemon(with query: String) {
        if query.isEmpty {
            filteredPokemonList = pokemonList
        } else {
            filteredPokemonList = pokemonList.filter {
                $0.name.lowercased().contains(query.lowercased())
            }
        }
        output?.didUpdateFilteredList()
    }
}
