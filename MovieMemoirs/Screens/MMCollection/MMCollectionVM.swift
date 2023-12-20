//
//  MMCollectionVM.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 19/12/2023.
//

import Foundation

protocol MMCollectionVMDelegates: AnyObject {
    
}


class MMCollectionVM {
    weak var delegate: MMCollectionVMDelegates?
    
}
