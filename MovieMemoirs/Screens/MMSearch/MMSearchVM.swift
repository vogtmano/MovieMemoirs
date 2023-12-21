//
//  MMSearchVM.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 18/12/2023.
//

import UIKit

protocol MMSearchVMDelegates: AnyObject {
    func presentAlert()
    func setImageTransformToIdentity()
    func setImage(to transform: CGAffineTransform)
}

class MMSearchVM {
    weak var delegate: MMSearchVMDelegates?
    weak var navigationController: UINavigationController?
    var timer: Timer?
    var currentAnimation = 0
    var isAnimating = true
    
    func symbolTapped(text: String?) {
        guard let title = text, !title.isEmpty else {
            delegate?.presentAlert()
            return
        }
        
        let collection = CollectionVC()
        collection.movieTitle = title
        
        if let navigationController {
            navigationController.pushViewController(collection, animated: true)
        } else {
          print("Warning: No navigation controller found.")
        }
    }
    
    func startAutomaticAnimation() {
        if timer == nil || !timer!.isValid {
            timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true, block: { [weak self] _ in self?.performAnimation() })
        }
    }
    
    @objc func performAnimation() {
        switch self.currentAnimation {
        case 1, 3, 5, 7:
            delegate?.setImageTransformToIdentity()
        case 0:
            delegate?.setImage(to: CGAffineTransform(translationX: -19, y: -19))
        case 2:
            delegate?.setImage(to: CGAffineTransform(translationX: 19, y: -19))
        case 4:
            delegate?.setImage(to: CGAffineTransform(translationX: 19, y: 19))
        case 6:
            delegate?.setImage(to: CGAffineTransform(translationX: -19, y: 19))
        default:
            break
        }
        currentAnimation += 1
        
        if currentAnimation > 7 {
            currentAnimation = 0
        }
    }
}
