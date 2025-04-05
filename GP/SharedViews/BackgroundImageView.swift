//
//  BackgroundImageView.swift
//  GP
//
//  Created by Gulliver Raed on 4/1/25.
//

import UIKit

final class BackgroundImageView: UIImageView {

    init(){
        super.init(image: UIImage(named: Constants.backgroundImage))
        self.contentMode = .scaleAspectFill
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
