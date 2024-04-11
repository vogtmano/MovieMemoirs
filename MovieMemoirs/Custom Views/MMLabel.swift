//
//  MMLabel.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 11/04/2024.
//

import UIKit

class MMLabel: UILabel {
    init() {
        super.init(frame: .zero)
        numberOfLines = 0
        font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
