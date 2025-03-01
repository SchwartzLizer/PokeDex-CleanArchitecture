import XCTest
import SnapKit
@testable import Clean_Architecture

final class PokemonDetailViewControllerTests: XCTestCase {
    fileprivate var sut: PokemonDetailViewController!
    fileprivate var mockPresenter: MockPokemonDetailPresenter!
    private var window: UIWindow!
    
    override func setUp() {
        super.setUp()
        mockPresenter = MockPokemonDetailPresenter()
        sut = PokemonDetailViewController(presenter: mockPresenter)
        
        // Add to window hierarchy for alert presentation
        window = UIWindow()
        window.addSubview(sut.view)
        window.makeKeyAndVisible()
        
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        window = nil
        sut = nil
        mockPresenter = nil
        super.tearDown()
    }
    
    func testViewDidLoadCallsPresenter() {
        // Then
        XCTAssertTrue(mockPresenter.viewDidLoadCalled)
    }
    
    func testUpdateStateShowsLoadingIndicator() {
        // When
        sut.updateState(.loading)
        
        // Then
        XCTAssertTrue(sut.isLoadingIndicatorVisible)
    }
    
    func testUpdateStateWithLoadedData() {
        // Given
        let pokemon = PokemonDetail(
            id: 1,
            name: "Bulbasaur",
            height: 7,
            weight: 69,
            imageUrl: "https://example.com/bulbasaur.png",
            types: ["grass", "poison"],
            stats: [
                PokemonStats(name: "hp", value: 45),
                PokemonStats(name: "attack", value: 49)
            ]
        )
        
        // When
        sut.updateState(.loaded(pokemon))
        
        // Then
        XCTAssertFalse(sut.isLoadingIndicatorVisible)
        XCTAssertEqual(sut.title, pokemon.name)
        XCTAssertEqual(sut.nameText, pokemon.name)
        XCTAssertEqual(sut.idText, "#\(pokemon.id)")
        XCTAssertEqual(sut.numberOfTypes, pokemon.types.count)
        XCTAssertEqual(sut.numberOfStats, pokemon.stats.count)
    }
    
    func testUpdateStateWithError() {
        // Given
        let expectation = self.expectation(description: "Wait for alert")
        let error = NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        // When
        sut.updateState(.error(error))
        
        // Allow time for alert to be presented
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Then
            XCTAssertFalse(self.sut.isLoadingIndicatorVisible)
            XCTAssertTrue(self.sut.isShowingError)
            XCTAssertEqual(self.sut.lastErrorMessage, "Failed to fetch Pokemon detail: \(error.localizedDescription)")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}

// MARK: - Mocks
private final class MockPokemonDetailPresenter: PokemonDetailPresenterInput {
    var viewDidLoadCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}

// MARK: - Test Helpers
private extension PokemonDetailViewController {
    var isLoadingIndicatorVisible: Bool {
        let mirror = Mirror(reflecting: self)
        let loadingIndicator = mirror.children.first { $0.label == "loadingIndicator" }?.value as? UIActivityIndicatorView
        return loadingIndicator?.isAnimating ?? false
    }
    
    var nameText: String? {
        let mirror = Mirror(reflecting: self)
        let nameLabel = mirror.children.first { $0.label == "nameLabel" }?.value as? UILabel
        return nameLabel?.text
    }
    
    var idText: String? {
        let mirror = Mirror(reflecting: self)
        let idLabel = mirror.children.first { $0.label == "idLabel" }?.value as? UILabel
        return idLabel?.text
    }
    
    var numberOfTypes: Int {
        let mirror = Mirror(reflecting: self)
        let stackView = mirror.children.first { $0.label == "typesStackView" }?.value as? UIStackView
        return stackView?.arrangedSubviews.count ?? 0
    }
    
    var numberOfStats: Int {
        let mirror = Mirror(reflecting: self)
        let stackView = mirror.children.first { $0.label == "statsStackView" }?.value as? UIStackView
        return stackView?.arrangedSubviews.count ?? 0
    }
    
    var isShowingError: Bool {
        let presentedVC = presentedViewController as? UIAlertController
        return presentedVC != nil
    }
    
    var lastErrorMessage: String? {
        let presentedVC = presentedViewController as? UIAlertController
        return presentedVC?.message
    }
}