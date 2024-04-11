//
//  PersistenceManager.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 09/04/2024.
//

import Foundation
import SwiftData

@MainActor
class PersistenceManager {
    static let shared = PersistenceManager()
    var container: ModelContainer?
    var context: ModelContext?
    
    private init() {
        do {
            let schema = Schema([MovieThumbnail.self])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            if let container {
                context = ModelContext(container)
            }
        } catch {
            print(error)
        }
    }
    
    func saveMovie(movieTitle: String, poster: String, id: String, year: String) {
        let movieToBeSaved = MovieThumbnail(title: movieTitle, poster: poster, id: id, year: year)
        context?.insert(movieToBeSaved)
    }
    
    func retrieveMovies() throws -> [MovieThumbnail] {
        let descriptor = FetchDescriptor<MovieThumbnail>()
        do {
            if let data = try context?.fetch(descriptor) {
                return data
            } else {
                throw MMError.persistenceFailRetrieving
            }
        } catch {
            throw MMError.persistenceFailRetrieving
        }
    }
    
    func updateFavourites(with movies: [MovieThumbnail]) {
        let descriptor = FetchDescriptor<MovieThumbnail>()
        do {
            guard let existingMovies = try? context?.fetch(descriptor) else { return }
            for existingMovie in existingMovies {
                if !movies.contains(where: { $0.id == existingMovie.id }) {
                    context?.delete(existingMovie)
                }
            }
            try? context?.save()
        }
    }
}
