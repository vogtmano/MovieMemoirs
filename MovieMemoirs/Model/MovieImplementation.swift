//
//  FilmImplementation.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 29/08/2023.
//

import UIKit
import Foundation

struct Movie: Decodable {
    var title: String
    var year: String
    var genre: String
    var director: String
    var isFavourite: Bool = false
    var actors: String
    var plot: String
    var awards: String
    var posterUrl: String
    var imdbID: String
    var boxOffice: String?
    
    var posterImage: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case genre = "Genre"
        case director = "Director"
        case actors = "Actors"
        case plot = "Plot"
        case awards = "Awards"
        case posterUrl = "Poster"
        case imdbID
        case boxOffice = "BoxOffice"
    }
}
