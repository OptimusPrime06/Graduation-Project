//
//  SignUpTextFields.swift
//  GP
//
//  Created by Gulliver Raed on 4/1/25.
//

import UIKit

final class SignUpTextFields: UITextField {

    init(placeholder : String, backgrounColor: String){
        super.init(frame: .zero)
        self.textColor = .white
        self.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        self.backgroundColor = UIColor(named: backgrounColor)
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = 12
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        self.leftView = padding
        self.leftViewMode = .always

        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
