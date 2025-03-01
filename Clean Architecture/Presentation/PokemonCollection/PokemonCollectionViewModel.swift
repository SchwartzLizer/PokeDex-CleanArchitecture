//
//  PokemonCollectionViewModel.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import Foundation

protocol PokemonCollectionViewModelInput {
    func fetchPokemonList()
    func loadMorePokemon()
    func searchPokemon(with query: String)
    var pokemonList: [Pokemon] { get }
    var filteredPokemonList: [Pokemon] { get }
    var isLoading: Bool { get }
    var canLoadMore: Bool { get }
}

protocol PokemonCollectionViewModelOutput: AnyObject {
    func didFetchPokemonList()
    func didFailFetchingPokemonList(_ error: Error)
    func didUpdateFilteredList()
    func didLoadMorePokemon()
}

final class PokemonCollectionViewModel: PokemonCollectionViewModelInput {
    weak var output: PokemonCollectionViewModelOutput?
    private let getPokemonListUseCase: GetPokemonListUseCase
    private let searchPokemonUseCase: SearchPokemonUseCase
    
    private(set) var pokemonList: [Pokemon] = []
    private(set) var filteredPokemonList: [Pokemon] = []
    private(set) var isLoading = false
    private(set) var canLoadMore = true
    
    private let pageSize = 20
    private var currentOffset = 0
    
    init(getPokemonListUseCase: GetPokemonListUseCase, searchPokemonUseCase: SearchPokemonUseCase) {
        self.getPokemonListUseCase = getPokemonListUseCase
        self.searchPokemonUseCase = searchPokemonUseCase
    }
    
    func fetchPokemonList() {
        guard !isLoading else { return }
        isLoading = true
        currentOffset = 0
        
        getPokemonListUseCase.execute(offset: currentOffset, limit: pageSize) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let pokemons):
                    self.pokemonList = pokemons
                    self.filteredPokemonList = pokemons
                    self.currentOffset += pokemons.count
                    self.canLoadMore = pokemons.count >= self.pageSize
                    self.output?.didFetchPokemonList()
                case .failure(let error):
                    self.output?.didFailFetchingPokemonList(error)
                }
            }
        }
    }
    
    func loadMorePokemon() {
        guard !isLoading, canLoadMore else { return }
        isLoading = true
        
        getPokemonListUseCase.execute(offset: currentOffset, limit: pageSize) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let newPokemons):
                    // Filter out Pokémon that are already in the list
                    let existingIds = Set(self.pokemonList.map { $0.id })
                    let uniqueNewPokemons = newPokemons.filter { !existingIds.contains($0.id) }
                    
                    if uniqueNewPokemons.isEmpty {
                        // If all Pokémon were duplicates, try loading the next page
                        self.currentOffset += newPokemons.count
                        self.loadMorePokemon()
                        return
                    }
                    
                    self.pokemonList.append(contentsOf: uniqueNewPokemons)
                    self.filteredPokemonList = self.pokemonList
                    self.currentOffset += newPokemons.count
                    self.canLoadMore = newPokemons.count >= self.pageSize
                    self.output?.didLoadMorePokemon()
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
