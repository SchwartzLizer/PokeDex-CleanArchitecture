//
//  HomeViewController.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import UIKit

final class HomeViewController: UIViewController {
    private let viewModel: HomeViewModelInput
    private let router: HomeRouting
    
    private let pokemonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let pokemonNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Refresh", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let showAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View All Pokémon", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
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
        view.backgroundColor = .white
        title = "Pokémon Home"
        
        view.addSubview(pokemonImageView)
        view.addSubview(pokemonNameLabel)
        view.addSubview(refreshButton)
        view.addSubview(activityIndicator)
        view.addSubview(showAllButton)
        
        NSLayoutConstraint.activate([
            pokemonImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pokemonImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            pokemonImageView.widthAnchor.constraint(equalToConstant: 200),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 200),
            
            pokemonNameLabel.topAnchor.constraint(equalTo: pokemonImageView.bottomAnchor, constant: 20),
            pokemonNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            pokemonNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            refreshButton.topAnchor.constraint(equalTo: pokemonNameLabel.bottomAnchor, constant: 30),
            refreshButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            showAllButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            showAllButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupActions() {
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        showAllButton.addTarget(self, action: #selector(showAllButtonTapped), for: .touchUpInside)
    }
    
    private func loadRandomPokemon() {
        activityIndicator.startAnimating()
        viewModel.fetchRandomPokemon()
    }
    
    @objc private func refreshButtonTapped() {
        loadRandomPokemon()
    }
    
    @objc private func showAllButtonTapped() {
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
