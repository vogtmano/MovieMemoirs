//
//  MMSearchVM.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 18/12/2023.
//

import UIKit
import OSLog

class MMSearchVM {
    protocol Delegate: AnyObject {
        func presentAlert()
        func setImageTransformToIdentity()
        func setImage(to transform: CGAffineTransform)
    }
    
    enum Action {
        case startAnimation
        case invalidateTimer
        case symbolTapped(String?)
    }
    
    static let logger = Logger(subsystem: "Interface", category: "Search")
    
    private var timer: Timer?
    private var currentAnimation = 0
    private var isAnimating = true
    
    weak var delegate: Delegate?
    weak var navigationController: UINavigationController?
    
    func handle(_ event: Action) {
        switch event {
        case .startAnimation:
            startAutomaticAnimation()
        case .invalidateTimer:
            invalidateTheTimer()
        case .symbolTapped(let text):
            symbolTapped(text: text)
        }
    }
}

private extension MMSearchVM {
    func symbolTapped(text: String?) {
        guard let title = text, !title.isEmpty else {
            delegate?.presentAlert()
            return
        }
        
        let viewModel = MMCollectionVM()
        let collection = CollectionVC(viewModel: viewModel)
        viewModel.navigationController = navigationController
        collection.viewModel.movieTitle = title
        
        guard let navigationController else {
            Self.logger.critical("Navigation Controller doesn't exist.")
            return
        }
        navigationController.pushViewController(collection, animated: true)
    }
    
    func startAutomaticAnimation() {
        if timer == nil || !(timer?.isValid ?? true) {
            timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] _ in self?.performAnimation()
            }
        }
    }
    
    func performAnimation() {
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
    
    func invalidateTheTimer() {
        timer?.invalidate()
    }
}
