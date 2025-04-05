//
//  StepNumberLabel.swift
//  GP
//
//  Created by Gulliver Raed on 4/1/25.
//

import UIKit

final class StepNumberLabel: UILabel {

    init(stepNumber : Int){
        super.init(frame: .zero)
        self.text = "Step \(stepNumber)"
        self.numberOfLines = 0
        self.font = .systemFont(ofSize: 40, weight: .bold)
        self.textColor = .white

        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
