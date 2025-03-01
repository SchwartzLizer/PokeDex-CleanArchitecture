//
//  PokemonDetailRouter.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import UIKit

protocol PokemonDetailRouting {
    // Add navigation methods if needed in the future
}

final class PokemonDetailRouter: PokemonDetailRouting {
    weak var viewController: UIViewController?
    
    init() {}
}

