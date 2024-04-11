//
//  MMMainStackView.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 11/04/2024.
//

import UIKit

class MovieStackView: UIStackView {
    init() {
        super.init(frame: .zero)
        alignment = .top
        layer.borderWidth = 1
        layer.borderColor = UIColor.darkGray.cgColor
        layer.cornerRadius = 8
        layoutMargins = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        isLayoutMarginsRelativeArrangement = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
