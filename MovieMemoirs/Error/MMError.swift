//
//  MMError.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 09/04/2024.
//

import Foundation

enum MMError: Error {
    case invalidURL
    case somethingWentWrong
    case persistenceFailRetrieving
    case noInternetConnection
    case badResponse
    
    var userFriendlyDescription: String {
        switch self {
        case .invalidURL:
            "The website is not working."
        case .somethingWentWrong:
            "Try to rewrite the title or check your internet connection."
        case .persistenceFailRetrieving:
            "Retrieving movies has failed."
        case .noInternetConnection:
            "No internet connection."
        case .badResponse:
            "Bad response."
        }
    }
}
