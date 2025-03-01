//
//  PokemonDetail.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import Foundation

struct PokemonDetailResponse: Decodable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let sprites: PokemonSprites
    let types: [PokemonTypeEntry]
    let stats: [PokemonStat]
}

struct PokemonSprites: Decodable {
    let frontDefault: String
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

struct PokemonTypeEntry: Decodable {
    let slot: Int
    let type: PokemonType
}

struct PokemonType: Decodable {
    let name: String
}

struct PokemonStat: Decodable {
    let baseStat: Int
    let stat: StatInfo
    
    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case stat
    }
}

struct StatInfo: Decodable {
    let name: String
}
