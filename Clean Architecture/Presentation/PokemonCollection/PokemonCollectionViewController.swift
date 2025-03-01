//
//  PokemonCollectionViewController.swift
//  Clean Architecture
//
//  Created by Tanatip Denduangchai on 3/1/25.
//

import UIKit
import SnapKit

final class PokemonCollectionViewController: UIViewController {
    private let viewModel: PokemonCollectionViewModelInput
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(PokemonCollectionViewCell.self, forCellWithReuseIdentifier: "PokemonCell")
        return collectionView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let loadingFooter: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    init(viewModel: PokemonCollectionViewModelInput) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        (viewModel as? PokemonCollectionViewModel)?.output = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchController()
        loadPokemonList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Pokémon Collection"
        
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        view.addSubview(loadingFooter)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        loadingFooter.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
        }
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Pokémon"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func loadPokemonList() {
        activityIndicator.startAnimating()
        viewModel.fetchPokemonList()
    }
}

extension PokemonCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filteredPokemonList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonCell", for: indexPath) as? PokemonCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let pokemon = viewModel.filteredPokemonList[indexPath.item]
        cell.configure(with: pokemon)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 30) / 2
        return CGSize(width: width, height: width * 1.2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}

extension PokemonCollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }
        viewModel.searchPokemon(with: query)
    }
}

extension PokemonCollectionViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !searchController.isActive else { return }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.bounds.height
        
        if offsetY > contentHeight - screenHeight - 100 {
            if !viewModel.isLoading && viewModel.canLoadMore {
                loadingFooter.startAnimating()
                viewModel.loadMorePokemon()
            }
        }
    }
}

extension PokemonCollectionViewController: PokemonCollectionViewModelOutput {
    func didFetchPokemonList() {
        activityIndicator.stopAnimating()
        collectionView.reloadData()
    }
    
    func didFailFetchingPokemonList(_ error: Error) {
        activityIndicator.stopAnimating()
        loadingFooter.stopAnimating()
        let alert = UIAlertController(title: "Error", message: "Failed to fetch Pokémon list: \(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func didUpdateFilteredList() {
        collectionView.reloadData()
    }
    
    func didLoadMorePokemon() {
        loadingFooter.stopAnimating()
        collectionView.reloadData()
    }
}
