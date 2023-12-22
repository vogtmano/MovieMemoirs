//
//  MMCollectionVM.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 19/12/2023.
//

import UIKit

protocol MMCollectionVMDelegates: AnyObject {
    
}


class MMCollectionVM {
    weak var delegate: MMCollectionVMDelegates?
    weak var navigationController: UINavigationController?
    var movieTitle = ""
    var movies = [MovieThumbnail]()
}
