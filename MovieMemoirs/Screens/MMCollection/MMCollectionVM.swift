//
//  MMCollectionVM.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 19/12/2023.
//

import UIKit

class MMCollectionVM {
    protocol Delegate: AnyObject {
        func applySnapshot()
    }
    
    enum Action {
        case viewDidLoad
    }
    
    weak var navigationController: UINavigationController?
    weak var delegate: Delegate?
    
    var movieTitle = ""
    var movies = [MovieThumbnail]()
    
    func handle(_ event: Action) {
        switch event {
        case .viewDidLoad:
            fetchMovies()
        }
    }
}

private extension MMCollectionVM {
    func fetchMovies() {
        Task { @MainActor in
            do {
                let result = await NetworkManager.shared.fetchFilms(with: movieTitle)
                
                switch result {
                case .success(let fetchedMovies):
                    movies = fetchedMovies
                    delegate?.applySnapshot()
                case .failure(let error):
                    let ac = UIAlertController(title: "Oops!",
                                               message: error.userFriendlyDescription,
                                               preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: returnToSearchVC))
                    navigationController?.present(ac, animated: true)
                }
            }
        }
    }
    
    func returnToSearchVC(action: UIAlertAction! = nil) {
        navigationController?.popViewController(animated: true)
    }
}
