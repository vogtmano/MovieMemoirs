//
//  FilmImplementation.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 29/08/2023.
//

import UIKit

struct DecodingMovie: Decodable {
    enum CodingKeys: String, CodingKey {
        case search = "Search"
    }
    
    let search: [MovieThumbnail]
}

struct MovieThumbnail: Codable, Hashable {
    var title: String
    var poster: String
    var id: String
    var year: String
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case poster = "Poster"
        case id = "imdbID"
        case year = "Year"
    }
}

struct Movie: Decodable, Hashable, Equatable {
    var title: String
    var year: String
    var genre: String
    var released: String
    var director: String
    var actors: String
    var plot: String
    var awards: String
    var posterUrl: String
    var imdbID: String
    var imdbRating: String
    var boxOffice: String
    
    var posterImage: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case genre = "Genre"
        case released = "Released"
        case director = "Director"
        case actors = "Actors"
        case plot = "Plot"
        case awards = "Awards"
        case posterUrl = "Poster"
        case imdbID
        case imdbRating = "imdbRating"
        case boxOffice = "BoxOffice"
    }
}
