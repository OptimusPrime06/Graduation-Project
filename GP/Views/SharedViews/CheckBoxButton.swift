//
//  CheckBoxButton.swift
//  GP
//
//  Created by Gulliver Raed on 3/27/25.
//

import UIKit

final class CheckBoxButton: UIButton {

    let checkedImage = UIImage(systemName: "checkmark")
//    let uncheckedImage = UIImage(systemName: "square")
    
    
    init(){
        super.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
//        self.setImage(uncheckedImage, for: .normal)
        self.setImage(checkedImage, for: .selected)
        self.backgroundColor = .clear
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(red: 0.20, green: 0.47, blue: 0.96, alpha: 1.00).cgColor
        self.layer.cornerRadius = 3
        self.addTarget(self, action: #selector(CheckBoxTapped), for: .touchUpInside)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func CheckBoxTapped(){
        self.isSelected.toggle()
    }
    
}
