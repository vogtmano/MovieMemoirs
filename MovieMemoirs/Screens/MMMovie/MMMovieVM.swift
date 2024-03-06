//
//  MMMovieVM.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 22/12/2023.
//

import UIKit

protocol MMMovieVMDelegates: AnyObject {
    func didFetchMovieDetails(film: Movie)
    func didFetchPoster(poster: UIImage)
}

class MMMovieVM {
    weak var delegate: MMMovieVMDelegates?
    var id: String
    var movie: Movie?
    
    init(id: String) {
        self.id = id
    }
    
    func fetchMovieDetails() {
        Task {
            do {
                let movie = try await NetworkManager.shared.fetchFilm(by: id)
                self.movie = movie
                delegate?.didFetchMovieDetails(film: movie)
                
                guard let poster = await NetworkManager.shared.fetchPoster(urlString: movie.posterUrl) else { return }
                delegate?.didFetchPoster(poster: poster)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
