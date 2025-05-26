//
//  ViewController.swift
//  GP
//
//  Created by Gulliver Raed on 3/3/25.
//

import UIKit
import FirebaseAuth

//MARK: - UI Components Initialization
private let backgroundImage = BackgroundImageView()

private let appLogo: UIImageView = {
    let appLogo = UIImageView(image: UIImage(named: "whiteEyes"))
    appLogo.contentMode = .scaleAspectFill
    
    appLogo.translatesAutoresizingMaskIntoConstraints = false
    
    return appLogo
}()

private let appName: UILabel = {
    let appName = UILabel()
    appName.text = Constants.appName
    appName.numberOfLines = 0
    appName.textColor = .white
    appName.font = .systemFont(ofSize: 32, weight: .bold)
    
    appName.translatesAutoresizingMaskIntoConstraints = false
    
    return appName
}()

private let emailTextField = SignUpTextFields(
    placeholder: "Email",
    backgrounColor: Constants.logIntextFieldBackgroundColor
)

private let passwordTextField = SignUpTextFields(
    placeholder: "Password",
    backgrounColor: Constants.logIntextFieldBackgroundColor
)

private let forgotPasswordButton: UIButton = {
    let forgotPassButton = UIButton()
    forgotPassButton.setAttributedTitle(
        NSAttributedString(
            string: "Forgot Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
        ), for: .normal)
    
    forgotPassButton.backgroundColor = UIColor(named: "backgroundColor")
    forgotPassButton.layer.borderWidth = 2
    forgotPassButton.layer.borderColor = UIColor.white.cgColor
    forgotPassButton.layer.cornerRadius = 7
    
    forgotPassButton.layer.shadowColor = UIColor.white.cgColor
    forgotPassButton.layer.shadowRadius = 3
    forgotPassButton.layer.shadowOffset = CGSize(width: 3, height: 3)
    forgotPassButton.layer.shadowOpacity = 1
    forgotPassButton.layer.masksToBounds = false
    
    forgotPassButton.translatesAutoresizingMaskIntoConstraints = false
    
    return forgotPassButton
}()

private let logInButton: UIButton = {
    let logInButton = UIButton()
    logInButton.setAttributedTitle(NSAttributedString(
        string: "Log In",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white,
                     NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                    ]),
                                   for: .normal)
    logInButton.backgroundColor = UIColor(named: "backgroundColor")
    logInButton.layer.borderWidth = 2
    logInButton.layer.borderColor = UIColor.white.cgColor
    logInButton.layer.cornerRadius = 3
    logInButton.layer.shadowColor = UIColor.white.cgColor
    logInButton.layer.shadowRadius = 3
    logInButton.layer.shadowOffset = CGSize(width: 3, height: 3)
    logInButton.layer.shadowOpacity = 1
    logInButton.layer.masksToBounds = false
    
    logInButton.translatesAutoresizingMaskIntoConstraints = false
    
    return logInButton
}()

private let createAccountButton: UIButton = {
    
    let createAccountButton = UIButton()
    createAccountButton.setAttributedTitle(NSAttributedString(
        string: "Create Account",
        attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .regular),
            NSAttributedString.Key.foregroundColor: UIColor.white,]),
                                           for: .normal)
    createAccountButton.layer.borderWidth = 1.5
    createAccountButton.layer.borderColor = UIColor.darkGray.cgColor
    createAccountButton.layer.cornerRadius = 7
    createAccountButton.backgroundColor = .clear
    
    createAccountButton.translatesAutoresizingMaskIntoConstraints = false
    
    return createAccountButton
}()

class LogInViewController: UIViewController {
    
    var logInViewModel : LogInViewModel?
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.textColor = .black
        passwordTextField.textColor = .black
        passwordTextField.isSecureTextEntry = true
        constraintsSetUp()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    //MARK: - Buttons functions
    @objc private func forgotPasswordButtonPressed() {
        print("forgot password button pressed")
    }
    
    @objc private func logInButtonPressed() {
        if emailTextField.text == "" || passwordTextField.text == "" {
            let alert = UIAlertController(title: "Missing Info", message: "Email or password is empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            guard let email = emailTextField.text, let password = passwordTextField.text else { return }
            
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let self = self else { return }
                
                if let error = error {
                    let alert = UIAlertController(title: "Login Failed", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                } else {
                    let mainTabBar = MainTabBarViewController()
                    
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        sceneDelegate.window?.rootViewController = mainTabBar
                        sceneDelegate.window?.makeKeyAndVisible()
                    }
                }
            }
        }
        
    }
    
    @objc private func createAccountButtonPressed(sender: UIButton) {
        let vc = CreateAccountStep1ViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension LogInViewController {
    
    //MARK: - UI Constraints function
    private func constraintsSetUp() {
        
        //Log In View
        view.addSubview(backgroundImage)
        view.addSubview(appLogo)
        view.addSubview(appName)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(forgotPasswordButton)
        view.addSubview(logInButton)
        view.addSubview(createAccountButton)
        
        //Background Image Constraints
        let backgroundImageConstraints = [
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        
        NSLayoutConstraint.activate(backgroundImageConstraints)
        
        // App logo image Constraints
        let appLogoConstraints = [
            appLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            appLogo.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 120),
            appLogo.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -120),
            appLogo.heightAnchor.constraint(equalToConstant: 200),
        ]
        
        NSLayoutConstraint.activate(appLogoConstraints)
        
        // App Name label Constraints
        let appNameLabelConstraints = [
            appName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appName.topAnchor.constraint(equalTo: appLogo.bottomAnchor, constant: -25),
            appName.heightAnchor.constraint(greaterThanOrEqualToConstant: 25),
        ]
        
        NSLayoutConstraint.activate(appNameLabelConstraints)
        
        //Email textField Constraints
        let emailTextFieldConstraints = [
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: appName.bottomAnchor, constant: 10),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        NSLayoutConstraint.activate(emailTextFieldConstraints)
        
        //Password textField Constraints
        let passwordTextFieldConstraints = [
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        NSLayoutConstraint.activate(passwordTextFieldConstraints)
        
        //ForgotPassword Button Contraints
        let forgotPasswordButtonConstraints = [
            forgotPasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            forgotPasswordButton.heightAnchor.constraint(equalToConstant: 40),
            forgotPasswordButton.widthAnchor.constraint(equalToConstant: 160),
        ]
        
        NSLayoutConstraint.activate(forgotPasswordButtonConstraints)
        
        //LogIn Button Constraints
        let logInButtonConstraints = [
            logInButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 20),
            logInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            logInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
            logInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logInButton.heightAnchor.constraint(equalToConstant: 40),
        ]
        
        NSLayoutConstraint.activate(logInButtonConstraints)
        
        //Create Account Button Constraints
        let createAccountButtonConstraints = [
            createAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createAccountButton.topAnchor.constraint(equalTo: logInButton.bottomAnchor, constant: 15),
            createAccountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 120),
            createAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -120),
        ]
        
        NSLayoutConstraint.activate(createAccountButtonConstraints)
        
        // Remove any existing targets before adding a new one
        forgotPasswordButton.removeTarget(nil, action: nil, for: .allEvents)
        logInButton.removeTarget(nil, action: nil, for: .allEvents)
        createAccountButton.removeTarget(nil, action: nil, for: .allEvents)
        
        //Adding Buttons functions
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonPressed),for: .touchUpInside)
        logInButton.addTarget(self, action: #selector(logInButtonPressed), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(createAccountButtonPressed),for: .touchUpInside)
        
    }
    
}

extension LogInViewController : UITextFieldDelegate {
    
    func textFieldsSetUp(){
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            return true
        }
    }
}

////MARK: - Preview
//#if DEBUG
//#Preview("Login View"){
//    LogInViewController()
//}
//#endif
