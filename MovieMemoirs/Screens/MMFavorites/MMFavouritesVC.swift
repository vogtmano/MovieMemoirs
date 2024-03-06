//
//  Favourites.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 11/08/2023.
//

import UIKit

class MMFavouritesVC: UICollectionViewController {
    enum Section {
        case main
    }
    
    let viewModel: MMFavouritesVM
    var dataSource: UICollectionViewDiffableDataSource<Section, MovieThumbnail>?
    let posterImage = UIImageView()
    let movieTitle = MMLabel()
    
    init(viewModel: MMFavouritesVM) {
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        title = "Favourite Movies"
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadMovie()
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
    
    func downloadMovie() {
        let favouritesData = UserDefaults.standard.data(forKey: "Favourites") ?? Data()
        let decodedFavourites = (try? JSONDecoder().decode([MovieThumbnail].self, from: favouritesData)) ?? []
        viewModel.movies = decodedFavourites
        applySnapshot()
    }
    
    @objc func shareTapped() {
        guard let image = posterImage.image else {
        print("No picture found") ; return }
    
        guard let title = movieTitle.text else { print("No title found") ; return }
        
        let vc = UIActivityViewController(activityItems: [image, title], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
        print("I've been tapped")
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MovieThumbnail>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.movies, toSection: .main)
        dataSource?.apply(snapshot)
    }
}

extension MMFavouritesVC: MMFavouritesVMDelegates {    
    func didFetchMovieDetails(film: Movie) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            movieTitle.text = film.title
        }
    }
    
    func didFetchPoster(poster: UIImage) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            posterImage.image = poster
        }
    }
}
