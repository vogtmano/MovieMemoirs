//
//  MMMovieVM.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 22/12/2023.
//

import UIKit

protocol MMMovieVMDelegates: AnyObject {
    
}


class MMMovieVM {
    weak var delegate: MMMovieVMDelegates?
    weak var navigationController: UINavigationController?
    var id: String
    
    
    init(id: String) {
        self.id = id
    }
}
