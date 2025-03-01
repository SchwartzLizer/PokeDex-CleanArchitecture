import Foundation

protocol SearchPokemonUseCase {
    func execute(name: String, completion: @escaping (Result<Pokemon, Error>) -> Void)
}

final class SearchPokemonUseCaseImpl: SearchPokemonUseCase {
    private let repository: PokemonRepository
    
    init(repository: PokemonRepository) {
        self.repository = repository
    }
    
    func execute(name: String, completion: @escaping (Result<Pokemon, Error>) -> Void) {
        repository.searchPokemon(name: name, completion: completion)
    }
}