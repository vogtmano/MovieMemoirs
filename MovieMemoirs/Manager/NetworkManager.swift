//
//  MovieNetworkManager.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 29/08/2023.
//

import UIKit

class NetworkManager {
    
    enum SearchType {
        case title
        case listOfTitles
        case id
        
        var searchSuffix: String {
            switch self {
            case .title:
                "t="
            case .listOfTitles:
                "s="
            case .id:
                "i="
            }
        }
    }
    
    static let shared = NetworkManager()
    private let apiKey = "&apikey=7d26b674"
    private let baseURL = "https://www.omdbapi.com/?"
    
    func fetchFilms(with title: String) async -> Result<[MovieThumbnail], MMError> {
        let urlString = baseURL + SearchType.listOfTitles.searchSuffix + title + apiKey
        guard let url = URL(string: urlString) else {
            return .failure(MMError.invalidURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let decodingObject = try decoder.decode(DecodingMovie.self, from: data)
            return .success(decodingObject.search)
            
        } catch {
            return .failure(MMError.networkError)
        }
    }
    
    func fetchPoster(urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
    
    func fetchFilm(by id: String) async throws -> Movie {
        let urlString = baseURL + SearchType.id.searchSuffix + id + apiKey
        guard let url = URL(string: urlString) else {
            throw MMError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let movie = try decoder.decode(Movie.self, from: data)
            return movie
        } catch {
            throw MMError.networkError
        }
    }
}
