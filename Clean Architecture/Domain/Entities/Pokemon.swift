//
//  Pokemon.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import Foundation

struct Pokemon {
    let id: Int
    let name: String
    let imageUrl: String
}

struct PokemonDetail {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let imageUrl: String
    let types: [String]
    let stats: [PokemonStats]
}

struct PokemonStats {
    let name: String
    let value: Int
}
