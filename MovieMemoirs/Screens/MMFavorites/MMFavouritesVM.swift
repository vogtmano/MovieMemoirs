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
    static let shared = MMFavouritesVM()
    weak var delegate: MMFavouritesVMDelegates?
    weak var navigationController: UINavigationController?
    var movies = [MovieThumbnail]()
}
