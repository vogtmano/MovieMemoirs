//
//  MovieNetworkManager.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 29/08/2023.
//

import Foundation

class NetworkManager {
    enum SearchType {
        case title
        case listOfTitles
        
        var searchSuffix: String {
            switch self {
            case .title:
                "t="
            case .listOfTitles:
                "s="
            }
        }
    }
    
    enum NetworkError: Error {
        case invalidURL
        case networkError
    }
    
    static let shared = NetworkManager()
    
    // http://www.omdbapi.com/?i=tt3896198&apikey=7d26b674 example
    private let apiKey = "&apikey=7d26b674"
    private let baseURL = "https://www.omdbapi.com/?"
    
    private init() {}
    
    func fetchFilms(with title: String) async -> Result<Movie, NetworkError> {
        let urlString = baseURL + SearchType.title.searchSuffix + title + apiKey
        guard let url = URL(string: urlString) else {
            return .failure(NetworkError.invalidURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let movies = try decoder.decode(Movie.self, from: data)
            return .success(movies)
        } catch {
            return .failure(NetworkError.networkError)
        }
    }
    
    func fetchFilm(with title: String) async -> Result<Movie?, NetworkError> {
        let urlString = baseURL + SearchType.title.searchSuffix + title + apiKey
        guard let url = URL(string: urlString) else {
            return .failure(NetworkError.invalidURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let movie = try decoder.decode(Movie.self, from: data)
            return .success(movie)
        } catch {
            return .failure(NetworkError.networkError)
        }
    }
}
