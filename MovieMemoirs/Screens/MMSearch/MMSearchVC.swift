//
//  ViewController.swift
//  MovieMemoirs
//
//  Created by Maks Vogtman on 09/08/2023.
//

import UIKit

class MMSearchVC: UIViewController {
    var imageView: UIImageView!
    var textField: UITextField!
    let viewModel: MMSearchVM
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLogo()
        setTextField()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startAutomaticAnimation()
        textField.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.timer?.invalidate()
    }
    
    init(viewModel: MMSearchVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setLogo() {
        imageView = UIImageView(image: UIImage(named: "logo"))
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleAnimation))
        imageView.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 350),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    func setTextField() {
        textField = UITextField()
        textField.delegate = self
        textField.placeholder = "Enter name of the movie"
        textField.font = .systemFont(ofSize: 25)
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1.5
        textField.clipsToBounds = true
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.textAlignment = .center
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let sfSymbol = UIImage(systemName: "magnifyingglass", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .light))
        let searchSymbol = UIImageView(image: sfSymbol)
        searchSymbol.tintColor = .systemYellow
        searchSymbol.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(symbolTapped))
        searchSymbol.addGestureRecognizer(tapGesture)
        
        textField.rightView = searchSymbol
        textField.rightViewMode = .always
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 50),
            textField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 75),
            textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    @objc func symbolTapped() {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        
        viewModel.symbolTapped(text: textField.text)
    }
    
    @objc func toggleAnimation() {
        viewModel.isAnimating.toggle()
        if viewModel.isAnimating {
            viewModel.startAutomaticAnimation()
        } else {
            viewModel.timer?.invalidate()
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let safeAreaBottom = view.safeAreaInsets.bottom
        let keyboardHeight = keyboardFrame.height
        let adjustment = textField.frame.maxY - (view.frame.height - keyboardHeight - safeAreaBottom) - 45
        
        if adjustment > 0 {
            view.frame.origin.y = -adjustment
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }

    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        textField.resignFirstResponder()
    }
}

extension MMSearchVC: MMSearchVMDelegates {
    func setImageTransformToIdentity() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
            self.imageView.transform = .identity
        }, completion: { _ in })
    }
    
    func setImage(to transform: CGAffineTransform) {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: [], animations: {
            self.imageView.transform = transform
        }, completion: { _ in })
    }
    
    func presentAlert() {
        let ac = UIAlertController(title: title, message: "You need to provide a title", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

extension MMSearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        
        viewModel.symbolTapped(text: textField.text)
        return true
    }
}
