//
//  CreateAccountStep1ViewController.swift
//  GP
//
//  Created by Gulliver Raed on 3/7/25.
//

import UIKit

//MARK: - Declaring UI components

private let backgroundImage = BackgroundImageView()

private let createAccountLabel = StepNumberLabel(stepNumber: 1)

private let progressBarView: SegmentedBarView = {
    
    let progressBarView = SegmentedBarView()
    let colors = [
        UIColor(named: Constants.currentPageColor)!,
        UIColor(named: Constants.nextPageColor)!,
        UIColor(named: Constants.nextPageColor)!,
        UIColor(named: Constants.nextPageColor)!
    ]
    let progressViewModel = SegmentedBarView.Model(
        colors: colors, spacing: 12
    )
    progressBarView.setModel(progressViewModel)
    
    progressBarView.translatesAutoresizingMaskIntoConstraints = false
    
    return progressBarView
}()

private let nameTextField = SignUpTextFields(placeholder: "Name", backgrounColor: Constants.signUpTextFieldsBackgroundColor)

private let emailTextField = SignUpTextFields(placeholder: "Email", backgrounColor: Constants.signUpTextFieldsBackgroundColor)

private let passwordTextField = SignUpTextFields(placeholder: "Password", backgrounColor: Constants.signUpTextFieldsBackgroundColor)

private let ageTextField = SignUpTextFields(placeholder: "Age", backgrounColor: Constants.signUpTextFieldsBackgroundColor)

private let maleGenderButton: UIButton = {
    
    let maleGenderButton = UIButton()
    maleGenderButton.backgroundColor = UIColor(
        named: Constants.signUpTextFieldsBackgroundColor)
    maleGenderButton.setAttributedTitle(
        NSAttributedString(
            string: "Male",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]),
        for: .normal)
    maleGenderButton.layer.borderWidth = 2
    maleGenderButton.layer.borderColor = UIColor.gray.cgColor
    maleGenderButton.layer.cornerRadius = 12
    maleGenderButton.contentHorizontalAlignment = .center
    
    maleGenderButton.translatesAutoresizingMaskIntoConstraints = false
    
    return maleGenderButton
}()

private let femaleGenderButton: UIButton = {
    
    let femaleGenderButton = UIButton()
    
    femaleGenderButton.backgroundColor = UIColor(
        named: Constants.signUpTextFieldsBackgroundColor)
    femaleGenderButton.setAttributedTitle(
        NSAttributedString(
            string: "Female",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]),
        for: .normal)
    femaleGenderButton.layer.borderWidth = 2
    femaleGenderButton.layer.borderColor = UIColor.gray.cgColor
    femaleGenderButton.layer.cornerRadius = 12
    femaleGenderButton.contentHorizontalAlignment = .center
    
    femaleGenderButton.translatesAutoresizingMaskIntoConstraints = false
    
    return femaleGenderButton
}()

private let genderStackView: UIStackView = {
    let genderStackView = UIStackView()
    genderStackView.axis = .horizontal
    genderStackView.distribution = .fillEqually
    genderStackView.spacing = 30
    genderStackView.addArrangedSubview(maleGenderButton)
    genderStackView.addArrangedSubview(femaleGenderButton)
    
    genderStackView.translatesAutoresizingMaskIntoConstraints = false
    
    return genderStackView
}()

private let driverExperiencDropDownMenu: UIButton = {
    
    let yearsOfExperience = Array(0...70)
    let actionClosure = { (action: UIAction) in
        print(action.title)
    }
    
    var config = UIButton.Configuration.plain()
    config.contentInsets = NSDirectionalEdgeInsets(
        top: 0, leading: 15, bottom: 0, trailing: 15)
    
    let driverExperiencDropDownMenu = UIButton(configuration: config, primaryAction: nil)
    driverExperiencDropDownMenu.backgroundColor = UIColor(named: "signUpTextFieldBackgroundColor")
    driverExperiencDropDownMenu.setTitleColor(.gray, for: .normal)
    driverExperiencDropDownMenu.layer.borderWidth = 2
    driverExperiencDropDownMenu.layer.borderColor = UIColor.gray.cgColor
    driverExperiencDropDownMenu.layer.cornerRadius = 12
    driverExperiencDropDownMenu.contentHorizontalAlignment = .leading
    
    //Set the placeholder text
    driverExperiencDropDownMenu.setTitle("Years Of Driving Experience", for: .normal)
    
    var menuChildren: [UIMenuElement] = []
    
    // Add placeholder as the first disabled option
    let placeholder = UIAction(title: "Years Of Driving Experience", attributes: .disabled, handler: actionClosure)
    menuChildren.append(placeholder)
    
    for years in yearsOfExperience {
        menuChildren.append(
            UIAction(title: String(years), handler: actionClosure))
    }
    
    driverExperiencDropDownMenu.menu = UIMenu(options: .displayInline, children: menuChildren)
    driverExperiencDropDownMenu.showsMenuAsPrimaryAction = true
    driverExperiencDropDownMenu.changesSelectionAsPrimaryAction = true
    driverExperiencDropDownMenu.translatesAutoresizingMaskIntoConstraints =
    false
    
    return driverExperiencDropDownMenu
}()

private let navigationButtons = NavigationButtons()


//MARK: - CreateAccountStep1ViewController Class

class CreateAccountStep1ViewController: UIViewController {
    
    var step1UserModel = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - Disabiling the Navigation Bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        UISetUp()
    }
    
    @objc func nextButtonTapped() {
        let vc = CreateAccountStep2ViewController()
        if emailTextField.text != "" || passwordTextField.text != "" {
            step1UserModel.setEmail(emailTextField.text!)
            step1UserModel.setPassword(passwordTextField.text!)
            vc.step2UserModel = self.step1UserModel
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let alert = UIAlertController(title: "Missing Info", message: "email or password is empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func genderButtonTapped(_ sender: UIButton) {
        // Reset both buttons to default appearance
        maleGenderButton.layer.borderColor = UIColor.gray.cgColor
        femaleGenderButton.layer.borderColor = UIColor.gray.cgColor
        maleGenderButton.setTitleColor(.gray, for: .normal)
        femaleGenderButton.setTitleColor(.gray, for: .normal)
        
        // Highlight the selected button
        sender.layer.borderColor = UIColor.blue.cgColor
        sender.setTitleColor(.blue, for: .normal)
        
        // Store the selected gender
        if sender == maleGenderButton {
            step1UserModel.setGender("Male")
        } else {
            step1UserModel.setGender("Female")
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension CreateAccountStep1ViewController {
    
    private func UISetUp() {
        
        view.addSubview(backgroundImage)
        view.addSubview(createAccountLabel)
        view.addSubview(progressBarView)
        view.addSubview(nameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(ageTextField)
        view.addSubview(genderStackView)
        view.addSubview(driverExperiencDropDownMenu)
        view.addSubview(navigationButtons)
        
        //Password TextField customization
        passwordTextField.isSecureTextEntry = true
        
        
        
        //Background Image Constraints
        let backgroundImageConstraints = [
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
        ]
        
        NSLayoutConstraint.activate(backgroundImageConstraints)
        
        //Step1 Label
        let setUpLabelConstraints = [
            createAccountLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            createAccountLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            createAccountLabel.heightAnchor.constraint(equalToConstant: 40),
        ]
        
        NSLayoutConstraint.activate(setUpLabelConstraints)
        
        //Prgress Bar Constraints
        let progressBarConstraints = [
            progressBarView.topAnchor.constraint(
                equalTo: createAccountLabel.bottomAnchor, constant: 30),
            progressBarView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            progressBarView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            progressBarView.heightAnchor.constraint(equalToConstant: 20),
        ]
        
        NSLayoutConstraint.activate(progressBarConstraints)
        
        //Name textField Constraints
        let nameTextFieldConstraints = [
            nameTextField.topAnchor.constraint(
                equalTo: progressBarView.bottomAnchor, constant: 30),
            nameTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
        ]
        
        NSLayoutConstraint.activate(nameTextFieldConstraints)
        
        //Email textField Constraints
        let emailTextFieldConstraints = [
            emailTextField.topAnchor.constraint(
                equalTo: nameTextField.bottomAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
        ]
        
        NSLayoutConstraint.activate(emailTextFieldConstraints)
        
        //Password textField Constraints
        let passwordTextFieldConstraints = [
            passwordTextField.topAnchor.constraint(
                equalTo: emailTextField.bottomAnchor, constant: 40),
            passwordTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
        ]
        
        NSLayoutConstraint.activate(passwordTextFieldConstraints)
        
        //Age textField Constraints
        let ageTextFieldConstraints = [
            ageTextField.topAnchor.constraint(
                equalTo: passwordTextField.bottomAnchor, constant: 40),
            ageTextField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            ageTextField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            ageTextField.heightAnchor.constraint(equalToConstant: 50),
        ]
        
        NSLayoutConstraint.activate(ageTextFieldConstraints)
        
        //Gender StackView Constraints
        let genderStackViewConstraints = [
            genderStackView.topAnchor.constraint(
                equalTo: ageTextField.bottomAnchor, constant: 40),
            genderStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            genderStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            genderStackView.heightAnchor.constraint(equalToConstant: 50),
        ]
        
        NSLayoutConstraint.activate(genderStackViewConstraints)
        
        //Driver Experience Button Constraints
        let driverExperienceMenuConstraints = [
            driverExperiencDropDownMenu.topAnchor.constraint(
                equalTo: genderStackView.bottomAnchor, constant: 40),
            driverExperiencDropDownMenu.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            driverExperiencDropDownMenu.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            driverExperiencDropDownMenu.heightAnchor.constraint(
                equalToConstant: 50),
        ]
        
        NSLayoutConstraint.activate(driverExperienceMenuConstraints)
        
        //Navigation StackView Constraints
        let navgationButtonsConstraints = [
            navigationButtons.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            navigationButtons.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            navigationButtons.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            navigationButtons.heightAnchor.constraint(equalToConstant: 50),
        ]
        
        NSLayoutConstraint.activate(navgationButtonsConstraints)
        
        // Remove any existing targets before adding a new one
        navigationButtons.backButton.removeTarget(nil, action: nil, for: .allEvents)
        navigationButtons.nextButton.removeTarget(nil, action: nil, for: .allEvents)
        
        //Adding Functions buttons
        navigationButtons.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        navigationButtons.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        maleGenderButton.addTarget(self, action: #selector(genderButtonTapped(_:)), for: .touchUpInside)
        femaleGenderButton.addTarget(self, action: #selector(genderButtonTapped(_:)), for: .touchUpInside)
    }
}



extension CreateAccountStep1ViewController : UITextFieldDelegate {
    
    func textFieldsSetUp(){
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            return true
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            return true
        }
    }
}

////MARK: - Preview
//#if DEBUG
//    #Preview("Sign Up 1 View") {
//        CreateAccountStep1ViewController()
//    }
//#endif
