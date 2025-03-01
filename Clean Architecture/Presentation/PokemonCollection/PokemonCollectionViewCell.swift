//
//  PokemonCollectionViewCell.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import UIKit

final class PokemonCollectionViewCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let idLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(idLabel)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            idLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            idLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            idLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    func configure(with pokemon: Pokemon) {
        nameLabel.text = pokemon.name
        idLabel.text = "#\(pokemon.id)"
        if let url = URL(string: pokemon.imageUrl) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                }
            }.resume()
        }
    }
}
