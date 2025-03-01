import XCTest
@testable import Clean_Architecture

final class PokemonDetailPresenterTests: XCTestCase {
    fileprivate var sut: PokemonDetailPresenter!
    fileprivate var mockInteractor: MockPokemonDetailInteractor!
    fileprivate var mockRouter: MockPokemonDetailRouter!
    fileprivate var mockOutput: MockPokemonDetailPresenterOutput!
    
    override func setUp() {
        super.setUp()
        mockInteractor = MockPokemonDetailInteractor()
        mockRouter = MockPokemonDetailRouter()
        mockOutput = MockPokemonDetailPresenterOutput()
        sut = PokemonDetailPresenter(interactor: mockInteractor, router: mockRouter, pokemonId: 1)
        sut.output = mockOutput
    }
    
    override func tearDown() {
        sut = nil
        mockInteractor = nil
        mockRouter = nil
        mockOutput = nil
        super.tearDown()
    }
    
    func testViewDidLoadStartsLoading() {
        // When
        sut.viewDidLoad()
        
        // Then
        XCTAssertTrue(mockOutput.updateStateCalled)
        XCTAssertEqual(mockOutput.lastState, .loading)
        XCTAssertTrue(mockInteractor.fetchPokemonDetailCalled)
        XCTAssertEqual(mockInteractor.lastFetchedId, 1)
    }
    
    func testDidFetchPokemonDetailSuccessfully() {
        // Given
        let pokemon = PokemonDetail(id: 1, name: "Bulbasaur", height: 7, weight: 69, imageUrl: "url", types: ["grass"], stats: [])
        
        // When
        sut.didFetchPokemonDetail(pokemon)
        
        // Then
        XCTAssertTrue(mockOutput.updateStateCalled)
        if case .loaded(let loadedPokemon) = mockOutput.lastState {
            XCTAssertEqual(loadedPokemon.id, pokemon.id)
            XCTAssertEqual(loadedPokemon.name, pokemon.name)
        } else {
            XCTFail("Expected .loaded state")
        }
    }
    
    func testDidFailFetchingPokemonDetail() {
        // Given
        let error = NSError(domain: "test", code: 0)
        
        // When
        sut.didFailFetchingPokemonDetail(error)
        
        // Then
        XCTAssertTrue(mockOutput.updateStateCalled)
        if case .error(let receivedError) = mockOutput.lastState {
            XCTAssertEqual(receivedError as NSError, error)
        } else {
            XCTFail("Expected .error state")
        }
    }
}

// MARK: - Mocks
private final class MockPokemonDetailInteractor: PokemonDetailInteractorInput {
    var fetchPokemonDetailCalled = false
    var lastFetchedId: Int?
    
    func fetchPokemonDetail(id: Int) {
        fetchPokemonDetailCalled = true
        lastFetchedId = id
    }
}

private final class MockPokemonDetailRouter: PokemonDetailRouting {
    var viewController: UIViewController?
}

private final class MockPokemonDetailPresenterOutput: PokemonDetailPresenterOutput {
    var updateStateCalled = false
    var lastState: PokemonDetailViewState?
    
    func updateState(_ state: PokemonDetailViewState) {
        updateStateCalled = true
        lastState = state
    }
}