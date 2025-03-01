//
//  PokemonDetailViewController.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import UIKit
import SnapKit
import Kingfisher

final class PokemonDetailViewController: UIViewController {
    private let viewModel: PokemonDetailViewModelInput
    private let pokemonId: Int
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView = UIView()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let idLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .center
        return label
    }()
    
    private let typesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        return stackView
    }()
    
    private let statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Initialization
    init(viewModel: PokemonDetailViewModelInput, pokemonId: Int) {
        self.viewModel = viewModel
        self.pokemonId = pokemonId
        super.init(nibName: nil, bundle: nil)
        (viewModel as? PokemonDetailViewModel)?.output = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchPokemonDetail()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [imageView, nameLabel, idLabel, typesStackView, statsStackView].forEach {
            contentView.addSubview($0)
        }
        
        view.addSubview(loadingIndicator)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(200)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        idLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        typesStackView.snp.makeConstraints { make in
            make.top.equalTo(idLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(typesStackView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func fetchPokemonDetail() {
        loadingIndicator.startAnimating()
        viewModel.fetchPokemonDetail(id: pokemonId)
    }
    
    private func updateUI() {
        guard let pokemon = viewModel.pokemon else { return }
        
        title = pokemon.name
        nameLabel.text = pokemon.name
        idLabel.text = "#\(pokemon.id)"
        
        if let url = URL(string: pokemon.imageUrl) {
            imageView.kf.setImage(
                with: url,
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]
            )
        }
        
        // Setup types
        typesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        pokemon.types.forEach { type in
            let typeLabel = UILabel()
            typeLabel.text = type.capitalized
            typeLabel.textAlignment = .center
            typeLabel.font = .systemFont(ofSize: 14, weight: .medium)
            typeLabel.backgroundColor = .systemBlue
            typeLabel.textColor = .white
            typeLabel.layer.cornerRadius = 8
            typeLabel.clipsToBounds = true
            typeLabel.snp.makeConstraints { make in
                make.height.equalTo(32)
            }
            typesStackView.addArrangedSubview(typeLabel)
        }
        
        // Setup stats
        statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        pokemon.stats.forEach { stat in
            let statView = createStatView(name: stat.name.capitalized, value: stat.value)
            statsStackView.addArrangedSubview(statView)
        }
    }
    
    private func createStatView(name: String, value: Int) -> UIView {
        let containerView = UIView()
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 14)
        
        let valueLabel = UILabel()
        valueLabel.text = "\(value)"
        valueLabel.font = .systemFont(ofSize: 14, weight: .medium)
        
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = Float(value) / 255.0
        progressView.progressTintColor = .systemGreen
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(valueLabel)
        containerView.addSubview(progressView)
        
        nameLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(100)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel.snp.trailing).offset(8)
            make.centerY.equalTo(nameLabel)
            make.width.equalTo(40)
        }
        
        progressView.snp.makeConstraints { make in
            make.leading.equalTo(valueLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(nameLabel)
            make.height.equalTo(4)
        }
        
        return containerView
    }
}

// MARK: - PokemonDetailViewModelOutput
extension PokemonDetailViewController: PokemonDetailViewModelOutput {
    func didFetchPokemonDetail() {
        loadingIndicator.stopAnimating()
        updateUI()
    }
    
    func didFailFetchingPokemonDetail(_ error: Error) {
        loadingIndicator.stopAnimating()
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to fetch Pokemon detail: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
