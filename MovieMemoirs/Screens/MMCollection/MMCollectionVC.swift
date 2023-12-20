//
//  Collection.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 11/08/2023.
//

import UIKit

class CollectionVC: UICollectionViewController {
    enum Section {
        case main
    }
    
    var movieTitle: String = "" {
        didSet {
            print(movieTitle)
        }
    }
    
    var movies: [MovieThumbnail] = []
    var dataSource: UICollectionViewDiffableDataSource<Section, MovieThumbnail>?
    
    init() {
        super.init(collectionViewLayout: UICollectionViewCompositionalLayout.list(using: .init(appearance: .plain)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        fetchMovies()
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, MovieThumbnail> { cell, indexPath, movie in
            var config = UIListContentConfiguration.cell()
            config.text = movie.title
            
            Task { @MainActor in
                config.image = await NetworkManager.shared.fetchPoster(urlString: movie.poster)
                cell.contentConfiguration = config
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, MovieThumbnail>(collectionView: collectionView) { collectionView, indexPath, movie in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: movie)
        }
    }
    
    func fetchMovies() {
        Task { @MainActor in
            do {
                let result = await NetworkManager.shared.fetchFilms(with: movieTitle)
                
                switch result {
                case .success(let fetchedMovies):
                    self.movies = fetchedMovies
                    applySnapshot()
                case .failure(let error):
                    print("Error fetching movies: \(error)")
                }
            }
        }
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MovieThumbnail>()
        snapshot.appendSections([.main])
        snapshot.appendItems(movies, toSection: .main)
        dataSource?.apply(snapshot)
    }
 
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        movies[indexPath.item]
    }
}
