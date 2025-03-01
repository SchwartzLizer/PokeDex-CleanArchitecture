//
//  PokemonCollectionPresenter.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

protocol PokemonCollectionPresenterInput {
    func viewDidLoad()
    func loadMorePokemon()
    func searchPokemon(query: String)
    func didSelectPokemon(at index: Int)
    func getPokemonList() -> [Pokemon]
}

protocol PokemonCollectionPresenterOutput: AnyObject {
    func updateState(_ state: PokemonCollectionViewState)
}

final class PokemonCollectionPresenter: PokemonCollectionPresenterInput {
    weak var output: PokemonCollectionPresenterOutput?
    private let interactor: PokemonCollectionInteractorInput
    private let router: PokemonCollectionRouting
    
    private var pokemonList: [Pokemon] = []
    private var filteredList: [Pokemon] = []
    private var isLoading = false
    private var canLoadMore = true
    private let pageSize = 20
    private var currentOffset = 0
    private var isSearching = false
    
    init(interactor: PokemonCollectionInteractorInput, router: PokemonCollectionRouting) {
        self.interactor = interactor
        self.router = router
    }
    
    func viewDidLoad() {
        output?.updateState(.loading)
        interactor.fetchPokemonList(offset: currentOffset, limit: pageSize)
    }
    
    func loadMorePokemon() {
        guard !isLoading, canLoadMore, !isSearching else { return }
        isLoading = true
        output?.updateState(.loadingMore)
        interactor.loadMorePokemon(offset: currentOffset, limit: pageSize)
    }
    
    func searchPokemon(query: String) {
        if query.isEmpty {
            isSearching = false
            filteredList = pokemonList
            output?.updateState(.loaded(PokemonCollectionModel(pokemonList: filteredList, isSearching: false)))
            return
        }
        isSearching = true
        interactor.searchPokemon(name: query.lowercased())
    }
    
    func didSelectPokemon(at index: Int) {
        let pokemon = filteredList[index]
        router.navigateToDetail(pokemonId: pokemon.id)
    }
    
    func getPokemonList() -> [Pokemon] {
        return filteredList
    }
}

extension PokemonCollectionPresenter: PokemonCollectionInteractorOutput {
    func didFetchPokemonList(_ pokemons: [Pokemon]) {
        pokemonList = pokemons
        filteredList = pokemons
        currentOffset = pokemons.count
        canLoadMore = pokemons.count >= pageSize
        isLoading = false
        
        output?.updateState(.loaded(PokemonCollectionModel(
            pokemonList: filteredList,
            isSearching: isSearching
        )))
    }
    
    func didFailFetchingPokemonList(_ error: Error) {
        isLoading = false
        output?.updateState(.error(error))
    }
    
    func didLoadMorePokemon(_ pokemons: [Pokemon]) {
        let existingIds = Set(pokemonList.map { $0.id })
        let uniqueNewPokemons = pokemons.filter { !existingIds.contains($0.id) }
        
        if uniqueNewPokemons.isEmpty {
            currentOffset += pokemons.count
            loadMorePokemon()
            return
        }
        
        pokemonList.append(contentsOf: uniqueNewPokemons)
        filteredList = pokemonList
        currentOffset += pokemons.count
        canLoadMore = pokemons.count >= pageSize
        isLoading = false
        
        output?.updateState(.loaded(PokemonCollectionModel(
            pokemonList: filteredList,
            isSearching: isSearching
        )))
    }
    
    func didSearchPokemon(_ pokemon: Pokemon?) {
        if let pokemon = pokemon {
            filteredList = [pokemon]
        } else {
            filteredList = pokemonList.filter { $0.name.lowercased().contains(pokemon?.name.lowercased() ?? "") }
        }
        output?.updateState(.loaded(PokemonCollectionModel(
            pokemonList: filteredList,
            isSearching: true
        )))
    }
}

