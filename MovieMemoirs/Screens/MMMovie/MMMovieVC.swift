//
//  MMMovieVC.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 29/08/2023.
//

import UIKit

class MMMovieVC: UIViewController {
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addToFavourites))
    }
    
    @objc func addToFavourites() {
        do {
            let decodedFavourites = try PersistenceManager.shared.retrieveMovies()
            if decodedFavourites.contains(where: { movie in
                viewModel.movie?.imdbID == movie.id
            }) {
                let ac = UIAlertController(title: "Already in Favourites",
                                           message: "That movie is already in your Favourites list",
                                           preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            } else {
                let ac = UIAlertController(title: "Add to Favourites",
                                           message: "Would you want to add that movie to your Favourites list?",
                                           preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: saveToFavourites))
                ac.addAction(UIAlertAction(title: "No", style: .cancel))
                present(ac, animated: true)
            }
        } catch {
            presentAlert()
        }
    }
    
    @objc func saveToFavourites(action: UIAlertAction) {
        guard let movie = self.viewModel.movie else { return }
        PersistenceManager.shared.saveMovie(movieTitle: movie.title,
                                            poster: movie.posterUrl,
                                            id: movie.imdbID,
                                            year: movie.year)
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

