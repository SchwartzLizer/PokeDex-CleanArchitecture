import Foundation

protocol PokemonDetailViewModelInput {
    func fetchPokemonDetail(id: Int)
    var pokemon: PokemonDetail? { get }
}

protocol PokemonDetailViewModelOutput: AnyObject {
    func didFetchPokemonDetail()
    func didFailFetchingPokemonDetail(_ error: Error)
}

final class PokemonDetailViewModel: PokemonDetailViewModelInput {
    weak var output: PokemonDetailViewModelOutput?
    private let getPokemonDetailUseCase: GetPokemonDetailUseCase
    
    private(set) var pokemon: PokemonDetail?
    
    init(getPokemonDetailUseCase: GetPokemonDetailUseCase) {
        self.getPokemonDetailUseCase = getPokemonDetailUseCase
    }
    
    func fetchPokemonDetail(id: Int) {
        getPokemonDetailUseCase.execute(id: id) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let pokemonDetail):
                    self.pokemon = pokemonDetail
                    self.output?.didFetchPokemonDetail()
                case .failure(let error):
                    self.output?.didFailFetchingPokemonDetail(error)
                }
            }
        }
    }
}