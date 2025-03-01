import XCTest
@testable import Clean_Architecture

final class PokemonDetailInteractorTests: XCTestCase {
    fileprivate var sut: PokemonDetailInteractor!
    fileprivate var mockUseCase: MockGetPokemonDetailUseCase!
    fileprivate var mockOutput: MockPokemonDetailInteractorOutput!
    
    override func setUp() {
        super.setUp()
        mockUseCase = MockGetPokemonDetailUseCase()
        mockOutput = MockPokemonDetailInteractorOutput()
        sut = PokemonDetailInteractor(getPokemonDetailUseCase: mockUseCase)
        sut.output = mockOutput
    }
    
    override func tearDown() {
        sut = nil
        mockUseCase = nil
        mockOutput = nil
        super.tearDown()
    }
    
    func testFetchPokemonDetailSuccess() {
        // Given
        let expectation = self.expectation(description: "Fetch Pokemon Detail")
        let pokemon = PokemonDetail(id: 1, name: "Bulbasaur", height: 7, weight: 69, imageUrl: "url", types: ["grass"], stats: [])
        mockUseCase.result = .success(pokemon)
        
        // When
        sut.fetchPokemonDetail(id: 1)
        
        // Wait for async operations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Then
            XCTAssertTrue(self.mockUseCase.executeCalled)
            XCTAssertEqual(self.mockUseCase.lastRequestedId, 1)
            XCTAssertTrue(self.mockOutput.didFetchPokemonDetailCalled)
            XCTAssertEqual(self.mockOutput.lastFetchedPokemon?.id, pokemon.id)
            XCTAssertEqual(self.mockOutput.lastFetchedPokemon?.name, pokemon.name)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFetchPokemonDetailFailure() {
        // Given
        let expectation = self.expectation(description: "Fetch Pokemon Detail Error")
        let error = NSError(domain: "test", code: 0)
        mockUseCase.result = .failure(error)
        
        // When
        sut.fetchPokemonDetail(id: 1)
        
        // Wait for async operations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Then
            XCTAssertTrue(self.mockUseCase.executeCalled)
            XCTAssertEqual(self.mockUseCase.lastRequestedId, 1)
            XCTAssertTrue(self.mockOutput.didFailFetchingPokemonDetailCalled)
            XCTAssertEqual(self.mockOutput.lastError as NSError?, error)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}

// MARK: - Mocks
private final class MockGetPokemonDetailUseCase: GetPokemonDetailUseCase {
    var executeCalled = false
    var lastRequestedId: Int?
    var result: Result<PokemonDetail, Error>?
    
    func execute(id: Int, completion: @escaping (Result<PokemonDetail, Error>) -> Void) {
        executeCalled = true
        lastRequestedId = id
        if let result = result {
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}

private final class MockPokemonDetailInteractorOutput: PokemonDetailInteractorOutput {
    var didFetchPokemonDetailCalled = false
    var lastFetchedPokemon: PokemonDetail?
    var didFailFetchingPokemonDetailCalled = false
    var lastError: Error?
    
    func didFetchPokemonDetail(_ pokemon: PokemonDetail) {
        didFetchPokemonDetailCalled = true
        lastFetchedPokemon = pokemon
    }
    
    func didFailFetchingPokemonDetail(_ error: Error) {
        didFailFetchingPokemonDetailCalled = true
        lastError = error
    }
}