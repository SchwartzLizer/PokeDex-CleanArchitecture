//
//  HomeViewModelTests.swift
//  Clean ArchitectureTests
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import XCTest
@testable import Clean_Architecture

class MockGetRandomPokemonUseCase: GetRandomPokemonUseCase {
    var mockResult: Result<Pokemon, Error>?
    
    func execute(completion: @escaping (Result<Pokemon, Error>) -> Void) {
        if let result = mockResult {
            completion(result)
        }
    }
}

class MockHomeViewModelOutput: HomeViewModelOutput {
    var didFetchRandomPokemonCalled = false
    var fetchedPokemon: Pokemon?
    var didFailFetchingRandomPokemonCalled = false
    var fetchError: Error?
    
    func didFetchRandomPokemon(_ pokemon: Pokemon) {
        didFetchRandomPokemonCalled = true
        fetchedPokemon = pokemon
    }
    
    func didFailFetchingRandomPokemon(_ error: Error) {
        didFailFetchingRandomPokemonCalled = true
        fetchError = error
    }
}

class HomeViewModelTests: XCTestCase {
    var sut: HomeViewModel!
    var mockUseCase: MockGetRandomPokemonUseCase!
    var mockOutput: MockHomeViewModelOutput!
    
    override func setUp() {
        super.setUp()
        mockUseCase = MockGetRandomPokemonUseCase()
        sut = HomeViewModel(getRandomPokemonUseCase: mockUseCase)
        mockOutput = MockHomeViewModelOutput()
        sut.output = mockOutput
    }
    
    override func tearDown() {
        sut = nil
        mockUseCase = nil
        mockOutput = nil
        super.tearDown()
    }
    
    func testFetchRandomPokemon_Success() {
        // Given
        let mockPokemon = Pokemon(id: 25, name: "Pikachu", imageUrl: "https://example.com/pikachu.png")
        mockUseCase.mockResult = .success(mockPokemon)
        
        // When
        sut.fetchRandomPokemon()
        
        // Then
        let expectation = self.expectation(description: "Wait for async call")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockOutput.didFetchRandomPokemonCalled)
            XCTAssertEqual(self.mockOutput.fetchedPokemon?.id, 25)
            XCTAssertEqual(self.mockOutput.fetchedPokemon?.name, "Pikachu")
            XCTAssertFalse(self.mockOutput.didFailFetchingRandomPokemonCalled)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFetchRandomPokemon_Failure() {
        // Given
        let mockError = NetworkError.serverError("500")
        mockUseCase.mockResult = .failure(mockError)
        
        // When
        sut.fetchRandomPokemon()
        
        // Then
        let expectation = self.expectation(description: "Wait for async call")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.mockOutput.didFetchRandomPokemonCalled)
            XCTAssertTrue(self.mockOutput.didFailFetchingRandomPokemonCalled)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
