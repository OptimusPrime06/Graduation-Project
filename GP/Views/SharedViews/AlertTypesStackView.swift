//
//  AlertTypesStackView.swift
//  GP
//
//  Created by Gulliver Raed on 3/26/25.
//

import UIKit

final class AlertTypesStackView: UIStackView {
    
    let checkBox1 = CheckBoxButton()
    let checkBox2 = CheckBoxButton()
    
    private let soundAlertImage : UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "speaker.wave.3"))
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let soundAlertLabel : UILabel = {
        
        let label = UILabel()
        label.text = "Sound"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let soundAlertStackView : UIStackView = {
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
        
    }()
    
    private let lightAlertImage : UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "lightbulb.max.fill"))
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let lightAlertLabel : UILabel = {
        
        let label = UILabel()
        label.text = "Light"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let lightAlertStackView : UIStackView = {
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
        
    }()
    
    init(){
        super.init(frame: .zero)
        SetUp()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func SetUp(){
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        //Sound StackView Set Up
        soundAlertStackView.addArrangedSubview(checkBox1)
        soundAlertStackView.addArrangedSubview(soundAlertImage)
        soundAlertStackView.addArrangedSubview(soundAlertLabel)
        
        //light StackView Set Up
        lightAlertStackView.addArrangedSubview(checkBox2)
        lightAlertStackView.addArrangedSubview(lightAlertImage)
        lightAlertStackView.addArrangedSubview(lightAlertLabel)
        
        
        //Alert StackView Set Up
        self.axis = .horizontal
        self.spacing = 10
        self.distribution = .fillEqually
        self.addArrangedSubview(soundAlertStackView)
        self.addArrangedSubview(lightAlertStackView)
        
    }
    
    
    
}
