//
//  PokemonList.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import Foundation

struct PokemonListResponse: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonResult]
}

struct PokemonResult: Decodable {
    let name: String
    let url: String
}
