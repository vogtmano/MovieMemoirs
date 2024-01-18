//
//  Favourites.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 11/08/2023.
//

import UIKit

class MMFavouritesVC: UITableViewController {
    private var movies: Set<String>
    let posterImage = UIImageView()
    let movieTitle = UILabel()
    let viewModel: MMFavouritesVM
    
    init(viewModel: MMFavouritesVM) {
        self.viewModel = viewModel
        movies = []
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        title = "Favourite Movies"
    }
    
    @objc func shareTapped() {
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = movieTitle.text
        cell.imageView?.image = posterImage.image
        return cell
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
