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
    private let searchPokemonUseCase: SearchPokemonUseCase
    
    private(set) var pokemonList: [Pokemon] = []
    private(set) var filteredPokemonList: [Pokemon] = []
    
    init(getPokemonListUseCase: GetPokemonListUseCase, searchPokemonUseCase: SearchPokemonUseCase) {
        self.getPokemonListUseCase = getPokemonListUseCase
        self.searchPokemonUseCase = searchPokemonUseCase
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
            output?.didUpdateFilteredList()
            return
        }
        
        searchPokemonUseCase.execute(name: query) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let pokemon):
                    self.filteredPokemonList = [pokemon]
                    self.output?.didUpdateFilteredList()
                case .failure:
                    // If search fails, fall back to local filtering
                    self.filteredPokemonList = self.pokemonList.filter {
                        $0.name.lowercased().contains(query.lowercased())
                    }
                    self.output?.didUpdateFilteredList()
                }
            }
        }
    }
}
