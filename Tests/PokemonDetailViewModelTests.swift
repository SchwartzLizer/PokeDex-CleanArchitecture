import XCTest
@testable import Clean_Architecture

final class PokemonDetailViewModelTests: XCTestCase {
    fileprivate var sut: PokemonDetailViewModel!
    fileprivate var mockUseCase: MockGetPokemonDetailUseCase!
    fileprivate var mockOutput: MockPokemonDetailViewModelOutput!
    
    override func setUp() {
        super.setUp()
        mockUseCase = MockGetPokemonDetailUseCase()
        mockOutput = MockPokemonDetailViewModelOutput()
        sut = PokemonDetailViewModel(getPokemonDetailUseCase: mockUseCase)
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
            XCTAssertEqual(self.sut.pokemon?.id, pokemon.id)
            XCTAssertEqual(self.sut.pokemon?.name, pokemon.name)
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
            XCTAssertNil(self.sut.pokemon)
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

private final class MockPokemonDetailViewModelOutput: PokemonDetailViewModelOutput {
    var didFetchPokemonDetailCalled = false
    var didFailFetchingPokemonDetailCalled = false
    
    func didFetchPokemonDetail() {
        didFetchPokemonDetailCalled = true
    }
    
    func didFailFetchingPokemonDetail(_ error: Error) {
        didFailFetchingPokemonDetailCalled = true
    }
}