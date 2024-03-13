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
    
    var dataSource: UICollectionViewDiffableDataSource<Section, MovieThumbnail>?
    let viewModel: MMCollectionVM
    
    init(viewModel: MMCollectionVM) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: UICollectionViewCompositionalLayout { _,_ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .absolute(90))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
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
                config.imageProperties.maximumSize = CGSize(width: 70, height: 70)
                cell.contentConfiguration = config
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, MovieThumbnail>(collectionView: collectionView) { collectionView, indexPath, movie in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: movie)
        }
    }
    
    // The fetchMovies method is responsible for fetching the list of movies based on the search title from the network. It's using the NetworkManager to fetch the data.
    func fetchMovies() {
        Task { @MainActor in
            do {
                let result = await NetworkManager.shared.fetchFilms(with: viewModel.movieTitle)
                
                switch result {
                case .success(let fetchedMovies):
                    self.viewModel.movies = fetchedMovies
                    applySnapshot()
                case .failure(let error):
                    print("Error fetching movies: \(error)")
                }
            }
        }
    }
    
    // The applySnapshot method is updating the UICollectionViewDiffableDataSource with the fetched movies.
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MovieThumbnail>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.movies, toSection: .main)
        dataSource?.apply(snapshot)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = viewModel.movies[indexPath.item]
        let movieVM = MMMovieVM(id: selectedMovie.id)
        let movieVC = MMMovieVC(viewModel: movieVM)
        navigationController?.pushViewController(movieVC, animated: true)        
    }
}
