//
//  PokemonCollectionViewCell.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import UIKit
import SnapKit
import Kingfisher

final class PokemonCollectionViewCell: UICollectionViewCell {
    // MARK: - Layout Constants
    private enum Layout {
        static let contentPadding: CGFloat = 10
        static let labelPadding: CGFloat = 8
        static let imageHeightMultiplier: CGFloat = 0.6
        static let cornerRadius: CGFloat = 10
        static let shadowRadius: CGFloat = 4
        static let shadowOpacity: Float = 0.1
    }
    
    // MARK: - UI Components
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private let idLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        nameLabel.text = nil
        idLabel.text = nil
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupViewHierarchy()
        setupConstraints()
        setupAppearance()
    }
    
    private func setupViewHierarchy() {
        [imageView, nameLabel, idLabel].forEach(contentView.addSubview)
    }
    
    private func setupAppearance() {
        backgroundColor = .systemBackground
        layer.cornerRadius = Layout.cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = Layout.shadowRadius
        layer.shadowOpacity = Layout.shadowOpacity
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Layout.contentPadding)
            make.leading.trailing.equalToSuperview().inset(Layout.contentPadding)
            make.height.equalToSuperview().multipliedBy(Layout.imageHeightMultiplier)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(Layout.labelPadding)
            make.leading.trailing.equalToSuperview().inset(Layout.labelPadding)
        }
        
        idLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(Layout.labelPadding/2)
            make.leading.trailing.equalToSuperview().inset(Layout.labelPadding)
            make.bottom.lessThanOrEqualToSuperview().offset(-Layout.contentPadding)
        }
    }
    
    // MARK: - Configuration
    func configure(with pokemon: Pokemon) {
        nameLabel.text = pokemon.name.capitalized
        idLabel.text = "#\(pokemon.id)"
        
        if let url = URL(string: pokemon.imageUrl) {
            imageView.kf.setImage(
                with: url,
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage,
                    .diskCacheExpiration(.days(7))
                ]
            )
        }
    }
}
