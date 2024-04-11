//
//  MMFavouritesVM.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 18/01/2024.
//

import UIKit

class MMFavouritesVM {
    protocol Delegate: AnyObject {
        func presentAlert()
        func didFetchMovieDetails(film: Movie)
        func didFetchPoster(poster: UIImage)
        func applySnapshot()
    }
    
    enum Action {
        case viewWillAppear
    }
    
    weak var delegate: Delegate?
    weak var navigationController: UINavigationController?
    var movies = [MovieThumbnail]()
    
    func handle(_ event: Action) {
        switch event {
        case .viewWillAppear:
            downloadMovies()
        }
    }
}

private extension MMFavouritesVM {
    func downloadMovies() {
        Task { @MainActor in
            do {
                let retrievedMovies = try PersistenceManager.shared.retrieveMovies()
                movies = retrievedMovies
                delegate?.applySnapshot()
            } catch {
                delegate?.presentAlert()
            }
        }
    }
}
