//
//  MMMovieVM.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 22/12/2023.
//

import UIKit

@MainActor class MMMovieVM {
    @MainActor protocol Delegate: AnyObject {
        func presentAlert()
        func didFetchMovieDetails(film: Movie)
        func didFetchPoster(poster: UIImage)
    }
    
    enum Action {
        case viewDidLoad
    }
    
    func handle(_ event: Action) {
        switch event {
        case .viewDidLoad:
            fetchMovieDetails()
        }
    }
    
    weak var delegate: Delegate?
    var id: String
    var movie: Movie?
    
    init(id: String) {
        self.id = id
    }
}

private extension MMMovieVM {
    func fetchMovieDetails() {
        Task {
            do {
                let movie = try await NetworkManager.shared.fetchFilm(by: id)
                self.movie = movie
                delegate?.didFetchMovieDetails(film: movie)
                
                guard let poster = await NetworkManager.shared.fetchPoster(urlString: movie.posterUrl) else { return }
                delegate?.didFetchPoster(poster: poster)
            } catch {
                delegate?.presentAlert()
            }
        }
    }
}
