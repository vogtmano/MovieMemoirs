//
//  UIImage ext.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 05/03/2024.
//

import Foundation
import UIKit

extension UIImageView {
    func loadImage(with imageUrl: String) {
        Task { @MainActor [weak self] in
            let image = await NetworkManager.shared.fetchPoster(urlString: imageUrl)
            self?.image = image
        }
    }
}
