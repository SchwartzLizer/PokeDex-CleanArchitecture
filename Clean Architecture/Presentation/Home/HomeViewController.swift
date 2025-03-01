//
//  HomeViewController.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import UIKit
import SnapKit
import Kingfisher

final class HomeViewController: UIViewController {
    // MARK: - Properties
    private let presenter: HomePresenterInput
    
    // MARK: - UI Components
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "PokéDex"
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var pokemonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }()
    
    private let pokemonNameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title1)
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var randomButton = createActionButton(
        title: "Random Pokémon",
        backgroundColor: .systemBlue,
        action: #selector(randomButtonTapped)
    )
    
    private lazy var collectionButton = createActionButton(
        title: "View Collection",
        backgroundColor: .systemGreen,
        action: #selector(collectionButtonTapped)
    )
    
    // MARK: - Lifecycle
    init(presenter: HomePresenterInput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRandomPokemon()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pokemonImageView.kf.cancelDownloadTask()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            randomButton.backgroundColor = .systemBlue
            collectionButton.backgroundColor = .systemGreen
        }
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(mainStackView)
        [titleLabel, pokemonImageView, pokemonNameLabel, randomButton, collectionButton].forEach {
            mainStackView.addArrangedSubview($0)
        }
        
        view.addSubview(activityIndicator)
        setupConstraints()
    }
    
    private func setupConstraints() {
        mainStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        pokemonImageView.snp.makeConstraints { make in
            make.size.equalTo(200)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(pokemonImageView)
        }
        
        [randomButton, collectionButton].forEach { button in
            button.snp.makeConstraints { make in
                make.width.equalTo(mainStackView).offset(-40)
            }
        }
    }
    
    private func createActionButton(title: String, backgroundColor: UIColor, action: Selector) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.baseBackgroundColor = backgroundColor
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        
        let button = UIButton(configuration: configuration)
        button.configurationUpdateHandler = { button in
            button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = .preferredFont(forTextStyle: .headline)
                return outgoing
            }
        }
        button.addTarget(self, action: action, for: .touchUpInside)
        button.layer.cornerRadius = 10
        
        return button
    }
    
    private func loadRandomPokemon() {
        presenter.presentRandomPokemon()
    }
    
    private func handleError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to fetch Pokémon: \(message)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Try Again", style: .default) { [weak self] _ in
            self?.loadRandomPokemon()
        })
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @objc private func randomButtonTapped() {
        loadRandomPokemon()
    }
    
    @objc private func collectionButtonTapped() {
        presenter.presentPokemonCollection()
    }
    
    @objc private func imageTapped() {
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.pokemonImageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.pokemonImageView.transform = .identity
            }
        }
    }
}

// MARK: - HomePresenterOutput
extension HomeViewController: HomePresenterOutput {
    func updateState(_ state: HomeViewState) {
        switch state {
        case .idle:
            activityIndicator.stopAnimating()
            
        case .loading:
            activityIndicator.startAnimating()
            pokemonImageView.image = nil
            pokemonNameLabel.text = "Loading..."
            
        case .loaded(let model):
            pokemonNameLabel.text = model.pokemon.name.capitalized
            
            if let url = URL(string: model.pokemon.imageUrl) {
                pokemonImageView.kf.setImage(
                    with: url,
                    placeholder: UIImage(systemName: "photo"),
                    options: [
                        .transition(.fade(0.3)),
                        .cacheOriginalImage,
                        .backgroundDecode,
                        .processor(DownsamplingImageProcessor(size: CGSize(width: 200, height: 200)))
                    ],
                    completionHandler: { [weak self] _ in
                        self?.activityIndicator.stopAnimating()
                    }
                )
            } else {
                activityIndicator.stopAnimating()
            }
            
        case .error(let error):
            activityIndicator.stopAnimating()
            pokemonNameLabel.text = "Error"
            handleError(error.localizedDescription)
        }
    }
}