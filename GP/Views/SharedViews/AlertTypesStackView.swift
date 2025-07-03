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
    
    private let soundAlertImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "speaker.wave.3"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let soundAlertLabel: UILabel = {
        let label = UILabel()
        label.text = "Sound"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let soundAlertStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let lightAlertImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "lightbulb.max.fill"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let lightAlertLabel: UILabel = {
        let label = UILabel()
        label.text = "Light"
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let lightAlertStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Initializer
    init(){
        super.init(frame: .zero)
        setUp()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setUp(){
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Stack up the alert sections
        soundAlertStackView.addArrangedSubview(checkBox1)
        soundAlertStackView.addArrangedSubview(soundAlertImage)
        soundAlertStackView.addArrangedSubview(soundAlertLabel)
        
        lightAlertStackView.addArrangedSubview(checkBox2)
        lightAlertStackView.addArrangedSubview(lightAlertImage)
        lightAlertStackView.addArrangedSubview(lightAlertLabel)
        
        self.axis = .horizontal
        self.spacing = 10
        self.distribution = .fillEqually
        self.addArrangedSubview(soundAlertStackView)
        self.addArrangedSubview(lightAlertStackView)
        
        // Optional: Toggle logic
        checkBox1.addTarget(self, action: #selector(toggleCheckbox(_:)), for: .touchUpInside)
        checkBox2.addTarget(self, action: #selector(toggleCheckbox(_:)), for: .touchUpInside)
    }
    
    // MARK: - Checkbox Toggle
    @objc private func toggleCheckbox(_ sender: CheckBoxButton) {
        sender.isSelected.toggle()
        sender.setNeedsDisplay()
    }
    
    // MARK: - Get Selected Alerts
    func getSelectedAlertTypes() -> [String] {
        var selectedAlerts: [String] = []
        
        if checkBox1.isSelected {
            selectedAlerts.append("Sound")
        }
        
        if checkBox2.isSelected {
            selectedAlerts.append("Light")
        }
        
        return selectedAlerts
    }
}
