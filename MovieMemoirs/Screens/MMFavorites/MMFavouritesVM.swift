//
//  MMFavouritesVM.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 18/01/2024.
//

import UIKit

protocol MMFavouritesVMDelegates: AnyObject {
    func didFetchMovieDetails(film: Movie)
    func didFetchPoster(poster: UIImage)
}

class MMFavouritesVM {
    weak var delegate: MMFavouritesVMDelegates?
    var movieThumbnail: MovieThumbnail?
    
    func fetchMovieDetails() {
        Task {
            do {
                let movie = try await NetworkManager.shared.fetchFilm(by: movieThumbnail!.id)
                delegate?.didFetchMovieDetails(film: movie)
                
                guard let poster = await NetworkManager.shared.fetchPoster(urlString: movie.posterUrl) else { return }
                delegate?.didFetchPoster(poster: poster)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
