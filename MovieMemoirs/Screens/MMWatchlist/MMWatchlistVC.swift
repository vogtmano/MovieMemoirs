//
//  MMWatchlistVC.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 18/04/2024.
//

import UIKit

@MainActor class MMWatchlistVC: UIViewController {
    enum Section {
        case main
    }
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: listLayout)
        view.addSubview(collectionView)
        collectionView.delegate = self
        return collectionView
    }()
    let posterImage = UIImageView()
    let movieTitle = MMLabel()

    var dataSource: UICollectionViewDiffableDataSource<Section, MovieThumbnail.ID>?
    let viewModel: MMWatchlistVM
    
    lazy var listLayout = UICollectionViewCompositionalLayout { _, layoutEnvironment in
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] (indexPath) in
            guard let item = self?.dataSource?.itemIdentifier(for: indexPath) else { return nil }
            let action = UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
                self?.viewModel.movies.removeAll { $0.id == item }
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
    
    init(viewModel: MMWatchlistVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Watchlist"
        setRightBarButtonItem()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.handle(.viewWillAppear)
    }
    
    func setRightBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                            target: self,
                                                            action: #selector(shareTapped))
    }
    
    @objc func shareTapped() {
        let shareTitle = "Check out my Watchlist!"
        let movieTitlesWithYears = viewModel.movies.map { "\($0.title) (\($0.year))" }.joined(separator: "\n")
        let shareMessage = """
        \(shareTitle)

        \(movieTitlesWithYears)
        """
        let activityItems = [shareMessage]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: [])
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityVC, animated: true)
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
        
        dataSource = UICollectionViewDiffableDataSource<Section, MovieThumbnail.ID>(collectionView: collectionView) { [weak self] collectionView, indexPath, _ in
            let movie = self?.viewModel.movies[indexPath.item]
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: movie)
        }
    }
}

extension MMWatchlistVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMovie = viewModel.movies[indexPath.item]
        let movieVM = MMMovieVM(id: selectedMovie.id)
        let movieVC = MMMovieVC(viewModel: movieVM)
        navigationController?.pushViewController(movieVC, animated: true)
    }
}

extension MMWatchlistVC: MMWatchlistVM.Delegate {
    func presentAlert() {
        let ac = UIAlertController(title: "Oops!",
                                   message: MMError.badResponse.userFriendlyDescription,
                                   preferredStyle: .alert)
        present(ac, animated: true)
    }
    
    func didFetchMovieDetails(film: Movie) {
        Task { @MainActor in
            movieTitle.text = film.title
        }
    }
    
    func didFetchPoster(poster: UIImage) {
        Task { @MainActor in
            posterImage.image = poster
        }
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MovieThumbnail.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.movies.map { $0.id }, toSection: .main)
        dataSource?.apply(snapshot)
        PersistenceManager.shared.updateMoviesList(with: viewModel.movies)
    }
}
