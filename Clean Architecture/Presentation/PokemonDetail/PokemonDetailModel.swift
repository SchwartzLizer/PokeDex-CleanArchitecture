//
//  PokemonDetailModel.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

enum PokemonDetailViewState: Equatable {
    case loading
    case loaded(PokemonDetail)
    case error(Error)
    
    static func == (lhs: PokemonDetailViewState, rhs: PokemonDetailViewState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.loaded(let lhsPokemon), .loaded(let rhsPokemon)):
            return lhsPokemon.id == rhsPokemon.id &&
                   lhsPokemon.name == rhsPokemon.name &&
                   lhsPokemon.height == rhsPokemon.height &&
                   lhsPokemon.weight == rhsPokemon.weight &&
                   lhsPokemon.imageUrl == rhsPokemon.imageUrl &&
                   lhsPokemon.types == rhsPokemon.types &&
                   lhsPokemon.stats.map { [$0.name, String($0.value)] } == rhsPokemon.stats.map { [$0.name, String($0.value)] }
        case (.error, .error):
            // We only check if both are errors, not the specific error
            // since Error doesn't conform to Equatable
            return true
        default:
            return false
        }
    }
}

