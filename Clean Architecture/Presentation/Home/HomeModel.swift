//
//  HomeModel.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

struct HomeModel {
    let pokemon: Pokemon
}

enum HomeViewState {
    case idle
    case loading
    case loaded(HomeModel)
    case error(Error)
}

