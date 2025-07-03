//
//  CreateAccountViewModel.swift
//  GP
//
//  Created by Gulliver Raed on 4/5/25.
//

import UIKit
import FirebaseAuth

class CreateAccountViewModel {
    
    let delegate : CreateAccountStep3ViewController?
        
    init(with createAccountData : UserModel, delegate : CreateAccountStep3ViewController){
        self.delegate = delegate
        Auth.auth().createUser(withEmail: createAccountData.getEmail()!, password: createAccountData.updatablePassword!) { authResult, error in
            if let signUpError = error {
                let alert = UIAlertController(title: "Sign up error", message: "\(signUpError.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
            } else {
                let vc = LogInViewController()
                self.delegate?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}
