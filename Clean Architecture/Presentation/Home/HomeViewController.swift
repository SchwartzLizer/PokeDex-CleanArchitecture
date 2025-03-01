//
//  HomeViewController.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import UIKit
import SnapKit

final class HomeViewController: UIViewController {
    private let viewModel: HomeViewModelInput
    private let router: HomeRouting
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "PokéDex"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    private let randomButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Random Pokémon", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        return button
    }()
    
    private let collectionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View Collection", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        return button
    }()
    
    init(viewModel: HomeViewModelInput, router: HomeRouting) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
        (viewModel as? HomeViewModel)?.output = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        loadRandomPokemon()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(randomButton)
        mainStackView.addArrangedSubview(collectionButton)
        
        mainStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    private func setupActions() {
        randomButton.addTarget(self, action: #selector(randomButtonTapped), for: .touchUpInside)
        collectionButton.addTarget(self, action: #selector(collectionButtonTapped), for: .touchUpInside)
    }
    
    private func loadRandomPokemon() {
        activityIndicator.startAnimating()
        viewModel.fetchRandomPokemon()
    }
    
    @objc private func randomButtonTapped() {
        loadRandomPokemon()
    }
    
    @objc private func collectionButtonTapped() {
        router.navigateToPokemonCollection()
    }
}

extension HomeViewController: HomeViewModelOutput {
    func didFetchRandomPokemon(_ pokemon: Pokemon) {
        pokemonNameLabel.text = pokemon.name
        
        if let url = URL(string: pokemon.imageUrl) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.pokemonImageView.image = image
                        self?.activityIndicator.stopAnimating()
                    }
                }
            }.resume()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func didFailFetchingRandomPokemon(_ error: Error) {
        activityIndicator.stopAnimating()
        let alert = UIAlertController(title: "Error", message: "Failed to fetch Pokémon: \(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
