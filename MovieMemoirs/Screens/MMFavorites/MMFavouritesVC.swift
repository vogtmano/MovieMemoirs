//
//  Favourites.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 11/08/2023.
//

import UIKit

class MMFavouritesVC: UIViewController {
    
    enum Section {
        case main
    }
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: listLayout)
        view.addSubview(collectionView)
        collectionView.delegate = self
        return collectionView
    }()
    
    lazy var listLayout = UICollectionViewCompositionalLayout { _, layoutEnvironment in
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] (indexPath) in
            guard let item = self?.dataSource?.itemIdentifier(for: indexPath) else { return nil }
            let action = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
                self?.viewModel.movies.removeAll { $0.id == item.id }
                self?.applySnapshot()
                completion(true)
            }
            return UISwipeActionsConfiguration(actions: [action])
        }
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(90))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
        return section
    }
    
    let viewModel: MMFavouritesVM
    var dataSource: UICollectionViewDiffableDataSource<Section, MovieThumbnail>?
    let posterImage = UIImageView()
    let movieTitle = MMLabel()
    
    init(viewModel: MMFavouritesVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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
        downloadMovies()
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
    
    func downloadMovies() {
        do {
            let retrievedMovies = try PersistenceManager.shared.retrieveMovies()
            viewModel.movies = retrievedMovies
            applySnapshot()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MovieThumbnail>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.movies, toSection: .main)
        dataSource?.apply(snapshot)
    }
    
    @objc func shareTapped() {
        let shareTitle = "Check out my Favourite Movies!"
        let movieTitlesWithYears = viewModel.movies.map { "\($0.title) (\($0.year))" }.joined(separator: "\n")
        let shareMessage = """
        \(shareTitle)

        \(movieTitlesWithYears)
        """
        let activityItems = [shareMessage]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: [])
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityVC, animated: true)
        
        print(activityItems)
    }
}

extension MMFavouritesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = viewModel.movies[indexPath.item]
        let movieVM = MMMovieVM(id: selectedMovie.id)
        let movieVC = MMMovieVC(viewModel: movieVM)
        navigationController?.pushViewController(movieVC, animated: true)
    }
}

extension MMFavouritesVC: Delegate {
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
