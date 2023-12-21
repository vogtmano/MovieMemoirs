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
        super.init(collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, environment in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let interItemSpacing: CGFloat = 2.0
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(90))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(interItemSpacing)
            let section = NSCollectionLayoutSection(group: group)
            return section
        })
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
            config.textProperties.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            config.textProperties.numberOfLines = 0
            
            Task { @MainActor in
                config.image = await NetworkManager.shared.fetchPoster(urlString: movie.poster)
                config.imageProperties.maximumSize = CGSize(width: 100, height: 100)
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
