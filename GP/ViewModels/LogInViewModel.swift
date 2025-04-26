//
//  LogInViewModel.swift
//  GP
//
//  Created by Gulliver Raed on 4/5/25.
//

import UIKit
import FirebaseAuth

class LogInViewModel {
    
    let delegate : LogInViewController?
    
    init(with email: String , with password: String, delegate: LogInViewController) {
        self.delegate = delegate
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let logInError = error {
                let alert = UIAlertController(title: "Log in up error", message: "\(logInError.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.delegate?.present(alert, animated: true)
                print(logInError.localizedDescription)
            } else {
                let vc = MapViewController()
                self?.delegate?.navigationController?.pushViewController(vc, animated: true)
            }          
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
