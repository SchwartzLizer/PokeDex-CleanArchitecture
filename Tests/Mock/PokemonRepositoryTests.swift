//
//  PokemonRepositoryTests.swift
//  Clean ArchitectureTests
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import XCTest
@testable import Clean_Architecture

class PokemonRepositoryTests: XCTestCase {
    var sut: PokemonRepositoryImpl!
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        sut = PokemonRepositoryImpl(networkService: mockNetworkService)
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    func testGetPokemonList_Success() {
        // Given
        let expectation = self.expectation(description: "Get Pokemon List")
        let mockResponse = PokemonListResponse(
            count: 2,
            next: nil,
            previous: nil,
            results: [
                PokemonResult(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
                PokemonResult(name: "ivysaur", url: "https://pokeapi.co/api/v2/pokemon/2/")
            ]
        )
        mockNetworkService.mockResult = .success(mockResponse)
        
        // When
        sut.getPokemonList(offset: 0, limit: 2) { result in
            // Then
            switch result {
            case .success(let pokemons):
                XCTAssertEqual(pokemons.count, 2)
                XCTAssertEqual(pokemons[0].name, "bulbasaur")
                XCTAssertEqual(pokemons[0].id, 1)
                XCTAssertEqual(pokemons[1].name, "ivysaur")
                XCTAssertEqual(pokemons[1].id, 2)
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testGetRandomPokemon_Success() {
        // Given
        let expectation = self.expectation(description: "Get Random Pokemon")
        let mockResponse = PokemonDetailResponse(
            id: 25,
            name: "pikachu",
            height: 4,
            weight: 60,
            sprites: PokemonSprites(frontDefault: "https://example.com/pikachu.png"),
            types: [PokemonTypeEntry(slot: 1, type: PokemonType(name: "electric"))],
            stats: [PokemonStat(baseStat: 35, stat: StatInfo(name: "hp"))]
        )
        mockNetworkService.mockResult = .success(mockResponse)
        
        // When
        sut.getRandomPokemon { result in
            // Then
            switch result {
            case .success(let pokemon):
                XCTAssertEqual(pokemon.id, 25)
                XCTAssertEqual(pokemon.name, "Pikachu")
                XCTAssertEqual(pokemon.imageUrl, "https://example.com/pikachu.png")
            case .failure:
                XCTFail("Expected success but got failure")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testGetPokemonDetail_Failure() {
        // Given
        let expectation = self.expectation(description: "Get Pokemon Detail Failure")
        mockNetworkService.mockResult = .failure(.serverError("404"))
        
        // When
        sut.getPokemonDetail(id: 1) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                guard let networkError = error as? NetworkError,
                      case .serverError(let errorMessage) = networkError else {
                    XCTFail("Expected NetworkError.serverError")
                    return
                }
                XCTAssertEqual(errorMessage, "404")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
