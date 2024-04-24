//
//  FilmImplementation.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 29/08/2023.
//

import UIKit
import SwiftData

struct DecodingMovie: Decodable {
    enum CodingKeys: String, CodingKey {
        case search = "Search"
    }
    
    let search: [MovieThumbnail]
}

@Model
class MovieThumbnail: Hashable, Identifiable, Decodable {
    var title: String
    var poster: String
    var id: String
    var year: String
    var isFavourite = false
    var isOnWatchlist = false
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case poster = "Poster"
        case id = "imdbID"
        case year = "Year"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.poster = try container.decode(String.self, forKey: .poster)
        self.id = try container.decode(String.self, forKey: .id)
        self.year = try container.decode(String.self, forKey: .year)
    }
    
    init(title: String, 
         poster: String,
         id: String, 
         year: String, 
         isFavourite: Bool = false,
         isOnWatchlist: Bool = false) {
        self.title = title
        self.poster = poster
        self.id = id
        self.year = year
        self.isFavourite = isFavourite
        self.isOnWatchlist = isOnWatchlist
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
    var bodyUI: [(label: String, copy: String)] {
        [
            ("Year", year),
            ("Genre", genre),
            ("Released", released),
            ("Director", director),
            ("Actors", actors),
            ("Awards", awards),
            ("imdbRating", imdbRating),
            ("BoxOffice", boxOffice)
        ]
    }
    
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
