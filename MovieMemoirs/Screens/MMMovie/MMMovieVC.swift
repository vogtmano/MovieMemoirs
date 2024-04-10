//
//  MMMovieVC.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 29/08/2023.
//

import UIKit

class MovieStackView: UIStackView {
   
    init() {
        super.init(frame: .zero)
        alignment = .top
        layer.borderWidth = 1
        layer.borderColor = UIColor.darkGray.cgColor
        layer.cornerRadius = 8
        layoutMargins = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        isLayoutMarginsRelativeArrangement = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MMLabel: UILabel {
    init() {
        super.init(frame: .zero)
        numberOfLines = 0
        font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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
    
    let yearHorizontalStackView = MovieStackView()
    let genreHorizontalStackView = MovieStackView()
    let releasedHorizontalStackView = MovieStackView()
    let directorHorizontalStackView = MovieStackView()
    let actorsHorizontalStackView = MovieStackView()
    let awardsHorizontalStackView = MovieStackView()
    let imdbRatingHorizontalStackView = MovieStackView()
    let boxOfficeHorizontalStackView = MovieStackView()
    
    let posterImage = UIImageView()
    let plotTextView = MMLabel()
    let yearLabel = MMLabel()
    let yearValueLabel = MMLabel()
    let genreLabel = MMLabel()
    let genreValueLabel = MMLabel()
    let releasedLabel = MMLabel()
    let releasedValueLabel = MMLabel()
    let directorLabel = MMLabel()
    let directorValueLabel = MMLabel()
    let actorsLabel = MMLabel()
    let actorsValueLabel = MMLabel()
    let awardsLabel = MMLabel()
    let awardsValueLabel = MMLabel()
    let imdbRatingLabel = MMLabel()
    let imdbRatingValueLabel = MMLabel()
    let boxOfficeLabel = MMLabel()
    let boxOfficeValueLabel = MMLabel()
    
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
        configureUI()
        viewModel.fetchMovieDetails()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToFavourites))
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
            fatalError()
        }
    }
    
    @objc func saveToFavourites(action: UIAlertAction) {
        guard let movie = self.viewModel.movie else { return }
        PersistenceManager.shared.saveMovie(movieTitle: movie.title, poster: movie.posterUrl, year: movie.year)
        
        let ac = UIAlertController(title: "Added to Favourites", 
                                   message: "The movie has been added to your Favourites list",
                                   preferredStyle: .actionSheet)
        let imageView = UIImageView(frame: CGRect(x: 10, y: 30, width: 25, height: 25))
        imageView.image = UIImage(systemName: "star.fill",
                                  withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .light))
        ac.view.addSubview(imageView)
        present(ac, animated: true)
        
        let deadline = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}

extension MMMovieVC: MMMovieVMDelegates {
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
            yearValueLabel.text = "Year"
            yearLabel.text = film.year
            genreValueLabel.text = "Genre"
            genreLabel.text = film.genre
            releasedValueLabel.text = "Released"
            releasedLabel.text = film.released
            directorValueLabel.text = "Director"
            directorLabel.text = film.director
            actorsValueLabel.text = "Actors"
            actorsLabel.text = film.actors
            awardsValueLabel.text = "Awards"
            awardsLabel.text = film.awards
            imdbRatingValueLabel.text = "IMDb Rating"
            imdbRatingLabel.text = film.imdbRating
            boxOfficeValueLabel.text = "Box office"
            boxOfficeLabel.text = film.boxOffice
        }
    }
}

private extension MMMovieVC {
    func configureUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(posterImage)
        mainStackView.addArrangedSubview(plotTextView)
        mainStackView.addArrangedSubview(yearHorizontalStackView)
        mainStackView.addArrangedSubview(genreHorizontalStackView)
        mainStackView.addArrangedSubview(releasedHorizontalStackView)
        mainStackView.addArrangedSubview(directorHorizontalStackView)
        mainStackView.addArrangedSubview(actorsHorizontalStackView)
        mainStackView.addArrangedSubview(awardsHorizontalStackView)
        mainStackView.addArrangedSubview(imdbRatingHorizontalStackView)
        mainStackView.addArrangedSubview(boxOfficeHorizontalStackView)
        
        yearHorizontalStackView.addArrangedSubview(yearValueLabel)
        yearHorizontalStackView.addArrangedSubview(yearLabel)
        genreHorizontalStackView.addArrangedSubview(genreValueLabel)
        genreHorizontalStackView.addArrangedSubview(genreLabel)
        releasedHorizontalStackView.addArrangedSubview(releasedValueLabel)
        releasedHorizontalStackView.addArrangedSubview(releasedLabel)
        directorHorizontalStackView.addArrangedSubview(directorValueLabel)
        directorHorizontalStackView.addArrangedSubview(directorLabel)
        actorsHorizontalStackView.addArrangedSubview(actorsValueLabel)
        actorsHorizontalStackView.addArrangedSubview(actorsLabel)
        awardsHorizontalStackView.addArrangedSubview(awardsValueLabel)
        awardsHorizontalStackView.addArrangedSubview(awardsLabel)
        imdbRatingHorizontalStackView.addArrangedSubview(imdbRatingValueLabel)
        imdbRatingHorizontalStackView.addArrangedSubview(imdbRatingLabel)
        boxOfficeHorizontalStackView.addArrangedSubview(boxOfficeValueLabel)
        boxOfficeHorizontalStackView.addArrangedSubview(boxOfficeLabel)
        
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

