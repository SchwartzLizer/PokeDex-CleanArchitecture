//
//  PokemonDetailModel.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

enum PokemonDetailViewState {
    case loading
    case loaded(PokemonDetail)
    case error(Error)
}

