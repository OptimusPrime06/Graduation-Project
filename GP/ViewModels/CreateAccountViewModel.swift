//
//  CreateAccountViewModel.swift
//  GP
//
//  Created by Gulliver Raed on 4/5/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateAccountViewModel {
    
    let delegate: CreateAccountStep3ViewController?
    
    init(with createAccountData: UserModel, delegate: CreateAccountStep3ViewController) {
        self.delegate = delegate
        
        Auth.auth().createUser(withEmail: createAccountData.getEmail()!, password: createAccountData.getPassword()!) { authResult, error in
            if let signUpError = error {
                let alert = UIAlertController(title: "Sign up error", message: signUpError.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.delegate?.present(alert, animated: true)
                return
            }
            
            guard let user = authResult?.user else { return }
            
            // Prepare user data
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "name": createAccountData.getName() ?? "",
                "email": createAccountData.getEmail() ?? "",
                "age": createAccountData.getAge() ?? 0,
                "gender": createAccountData.getGender() ?? "",
                "experience": createAccountData.getExperience() ?? "",
                "diseases": createAccountData.getDiseases() ?? "",
                "conditions": createAccountData.getConditions(),
                "otherConditions": createAccountData.getOtherConditions() ?? "",
                "emergencyContacts": createAccountData.getEmergencyContacts()
            ]
            
            print("Saving user to Firestore: \(userData)")
            
            db.collection("users").document(user.uid).setData(userData) { error in
                if let error = error {
                    print("Error saving user data: \(error)")
                    let alert = UIAlertController(title: "Error", message: "Failed to save user data: \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.delegate?.present(alert, animated: true)
                } else {
                    print("User data saved successfully!")
                    let vc = LogInViewController()
                    self.delegate?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
