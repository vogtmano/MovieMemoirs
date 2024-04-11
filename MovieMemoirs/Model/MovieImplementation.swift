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
class MovieThumbnail: Codable, Hashable {
    var title: String
    var poster: String
    var id: String
    var year: String
    
    init(title: String, poster: String, id: String, year: String) {
        self.title = title
        self.poster = poster
        self.id = id
        self.year = year
    }
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case poster = "Poster"
        case id = "imdbID"
        case year = "Year"
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        poster = try container.decode(String.self, forKey: .poster)
        id = try container.decode(String.self, forKey: .id)
        year = try container.decode(String.self, forKey: .year)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(poster, forKey: .poster)
        try container.encode(id, forKey: .id)
        try container.encode(year, forKey: .year)
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
