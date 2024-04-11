//
//  Collection.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 11/08/2023.
//

import UIKit

class MMCollectionVC: UICollectionViewController {
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

        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        viewModel.handle(.viewDidLoad)
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = viewModel.movies[indexPath.item]
        let movieVM = MMMovieVM(id: selectedMovie.id)
        let movieVC = MMMovieVC(viewModel: movieVM)
        navigationController?.pushViewController(movieVC, animated: true)
    }
}

extension MMCollectionVC: MMCollectionVM.Delegate {
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MovieThumbnail>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.movies, toSection: .main)
        dataSource?.apply(snapshot)
    }
}
