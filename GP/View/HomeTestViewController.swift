//
//  HomeTestViewController.swift
//  GP
//
//  Created by Gulliver Raed on 4/5/25.
//

import UIKit

class HomeTestViewController: UIViewController {
  
    private let backgroundImage = BackgroundImageView()
    
    private let WelcomeLabel : UILabel = {
        let label = UILabel()
        label.text = "Welcome to Sa7eeny"
        label.textColor = .white
        label.font = .systemFont(ofSize: 40)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backgroundImage)
        view.addSubview(WelcomeLabel)
        
        //Background Image Constraints
        let backgroundImageConstraints = [
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
        ]

        NSLayoutConstraint.activate(backgroundImageConstraints)
        
        WelcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        WelcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    

    

}
