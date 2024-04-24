//
//  MMMovieVC.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 29/08/2023.
//

import UIKit

@MainActor class MMMovieVC: UIViewController {
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var eyeButton = UIBarButtonItem()
    var starButton = UIBarButtonItem()
    let posterImage = UIImageView()
    let plotTextView = MMLabel()
    let viewModel: MMMovieVM
    
    init(viewModel: MMMovieVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRightBarButtonItem()
        configureUI()
        viewModel.handle(.viewDidLoad)
    }
    
    func setRightBarButtonItem() {
        eyeButton = UIBarButtonItem(image: UIImage(systemName: "eye"), style: .plain, target: self, action: #selector(saveToWatchlist))
        starButton = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: #selector(addToFavourites))
        navigationItem.rightBarButtonItems = [eyeButton, starButton]
    }
    
    @objc func addToFavourites() {
        do {
            let decodedFavourites = try PersistenceManager.shared.retrieveMovies()
            if decodedFavourites.contains(where: { movie in
                viewModel.movie?.imdbID == movie.id
            }) {
                
            } else {
                saveToFavourites()
                starButton.image = UIImage(systemName: "star.fill")
            }
        } catch {
            presentAlert()
        }
    }
    
    func saveToFavourites() {
        guard let movie = self.viewModel.movie else { return }
        PersistenceManager.shared.saveMovie(movieTitle: movie.title,
                                            poster: movie.posterUrl,
                                            id: movie.imdbID,
                                            year: movie.year, 
                                            listType: .favourites)
        let ac = UIAlertController(title: "Added to Favourites",
                                   message: "The movie has been added to your Favourites list",
                                   preferredStyle: .actionSheet)
        let imageView = UIImageView(frame: CGRect(x: 10, y: 30, width: 25, height: 25))
        imageView.image = UIImage(systemName: "star.fill",
                                  withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .light))
        ac.view.addSubview(imageView)
        present(ac, animated: true)
        
        let deadline = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    @objc func saveToWatchlist() {
        guard let movie = self.viewModel.movie else { return }
        PersistenceManager.shared.saveMovie(movieTitle: movie.title,
                                            poster: movie.posterUrl,
                                            id: movie.imdbID,
                                            year: movie.year, 
                                            listType: .watchlist)
        let ac = UIAlertController(title: "Added to Watchlist",
                                   message: "The movie has been added to your Watchlist",
                                   preferredStyle: .actionSheet)
        let imageView = UIImageView(frame: CGRect(x: 10, y: 30, width: 35, height: 25))
        imageView.image = UIImage(systemName: "eye.fill",
                                  withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .light))
        ac.view.addSubview(imageView)
        present(ac, animated: true)
        
        eyeButton.image = UIImage(systemName: "eye.fill")
        
        let deadline = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}

extension MMMovieVC: MMMovieVM.Delegate {
    func presentAlert() {
        let ac = UIAlertController(title: "Oops!",
                                   message: MMError.badResponse.userFriendlyDescription,
                                   preferredStyle: .alert)
        present(ac, animated: true)
    }
    
    func didFetchPoster(poster: UIImage) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            posterImage.image = poster
        }
    }
    
    func didFetchMovieDetails(film: Movie) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            plotTextView.text = film.plot
            plotTextView.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
            film.bodyUI.forEach { title, copy in
                let stackView = MovieStackView()
                let titleLabel = MMLabel()
                let copyLabel = MMLabel()
                titleLabel.text = title
                copyLabel.text = copy
                stackView.addArrangedSubview(titleLabel)
                stackView.addArrangedSubview(copyLabel)
                self.mainStackView.addArrangedSubview(stackView)
            }
        }
    }
}

private extension MMMovieVC {
    func configureUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(posterImage)
        mainStackView.addArrangedSubview(plotTextView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            mainStackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            mainStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
}

