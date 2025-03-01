//
//  PokemonCollectionModel.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

struct PokemonCollectionModel {
    let pokemonList: [Pokemon]
    let isSearching: Bool
}

enum PokemonCollectionViewState {
    case idle
    case loading
    case loaded(PokemonCollectionModel)
    case loadingMore
    case error(Error)
}

struct PokemonSearchModel {
    let searchResult: Pokemon?
    let localFilteredResults: [Pokemon]
}

