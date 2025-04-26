//
//  NavigationButtons.swift
//  GP
//
//  Created by Gulliver Raed on 3/26/25.
//

import UIKit

final class NavigationButtons: UIStackView {

    let backButton: UIButton = {
        let backButton = UIButton()
        backButton.setTitle("Back", for: .normal)
        backButton.backgroundColor = .clear
        backButton.tintColor = .gray
        backButton.layer.borderWidth = 2
        backButton.layer.borderColor = UIColor.gray.cgColor
        backButton.layer.cornerRadius = 12
        backButton.contentHorizontalAlignment = .center

        backButton.translatesAutoresizingMaskIntoConstraints = false

        return backButton
    }()

    let nextButton: UIButton = {

        let nextButton = UIButton()
        nextButton.setTitle("Next", for: .normal)
        nextButton.backgroundColor = UIColor(named: "nextButtonColor")
        nextButton.tintColor = .white
        nextButton.layer.borderWidth = 2
        nextButton.layer.borderColor = UIColor.gray.cgColor
        nextButton.layer.cornerRadius = 12
        nextButton.contentHorizontalAlignment = .center

        nextButton.translatesAutoresizingMaskIntoConstraints = false

        return nextButton
    }()

    init() {
        super.init(frame: .zero)
        self.axis = .horizontal
        self.spacing = 10
        self.distribution = .fillEqually
        self.addArrangedSubview(backButton)
        self.addArrangedSubview(nextButton)

        self.translatesAutoresizingMaskIntoConstraints = false
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
