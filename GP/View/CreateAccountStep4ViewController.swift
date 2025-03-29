//
//  CreateAccountStep4ViewController.swift
//  GP
//
//  Created by Gulliver Raed on 3/29/25.
//

import UIKit

//MARK: - Declaring UI components

private let backgroundImage: UIImageView = {

    let backgroundImage = UIImageView(image: UIImage(named: "backGround"))
    backgroundImage.contentMode = .scaleAspectFill
    backgroundImage.translatesAutoresizingMaskIntoConstraints = false

    return backgroundImage
}()

private let createAccountLabel: UILabel = {

    let createAccountLabel = UILabel()
    createAccountLabel.text = "Step 4"
    createAccountLabel.numberOfLines = 0
    createAccountLabel.font = .systemFont(ofSize: 40, weight: .bold)
    createAccountLabel.textColor = .white

    createAccountLabel.translatesAutoresizingMaskIntoConstraints = false

    return createAccountLabel
}()

private let progressBarView: SegmentedBarView = {

    let progressBarView = SegmentedBarView()
    let colors = [
        UIColor(named: "previousPageColor")!,
        UIColor(named: "previousPageColor")!,
        UIColor(named: "previousPageColor")!,
        UIColor(named: "currentPageColor")!,
    ]
    let progressViewModel = SegmentedBarView.Model(
        colors: colors, spacing: 12
    )
    progressBarView.setModel(progressViewModel)

    progressBarView.translatesAutoresizingMaskIntoConstraints = false

    return progressBarView
}()

private let emergencyContactsLabel: UILabel = {
    let label = UILabel()
    label.text = "Emergency Contacts (at least 2)"
    label.textColor = .white
    label.font = .systemFont(ofSize: 18, weight: .bold)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
}()

//private let emergenyContactsTextField : UITextField = {
//    let textField = UITextField()
//    textField.attributedPlaceholder = NSAttributedString(string: "Enter emergency contact", attributes: [
//        NSAttributedString.Key.foregroundColor : UIColor.gray
//    ])
//    textField.keyboardType = .phonePad
//    textField.backgroundColor = UIColor(
//        named: "signUpTextFieldBackgroundColor")
//    textField.layer.cornerRadius = 8
//    textField.layer.borderWidth = 2
//    textField.layer.borderColor = UIColor.gray.cgColor
//    textField.textColor = .white
//
//    let padding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
//    textField.leftView = padding
//    textField.leftViewMode = .always
//
//    textField.translatesAutoresizingMaskIntoConstraints = false
//    textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        
//    return textField
//}()

private let emergencyContactsStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 10
    
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    return stackView
}()

private let addContactButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("+ Add Contact", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = UIColor(named: "nextButtonColor")
    button.layer.cornerRadius = 8

    button.translatesAutoresizingMaskIntoConstraints = false

    return button
}()

private let navigationButtons = NavigationButtons()

class CreateAccountStep4ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - Disabiling the Navigation Bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        UISetUp()
    }

    @objc func addEmergencyContactField() {
        print("Ana dost add Contact")
        emergencyContactsStackView.addArrangedSubview(createEmergencyContactTextField())
    }

    @objc func createAccountButtonTapped() {

    }

    @objc func backButtonTapped() {
        let vc = CreateAccountStep3ViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension CreateAccountStep4ViewController {

    private func UISetUp() {

        view.addSubview(backgroundImage)
        view.addSubview(createAccountLabel)
        view.addSubview(progressBarView)
        view.addSubview(emergencyContactsLabel)
        view.addSubview(emergencyContactsStackView)
        view.addSubview(addContactButton)
        view.addSubview(navigationButtons)

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

        //Progress Bar Constraints
        let progressBarConstraints = [
            progressBarView.topAnchor.constraint(
                equalTo: createAccountLabel.bottomAnchor, constant: 20),
            progressBarView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            progressBarView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            progressBarView.heightAnchor.constraint(equalToConstant: 20),
        ]

        NSLayoutConstraint.activate(progressBarConstraints)

        //Emergency Contacts Label Constraints
        let emergencyContactsLabelConstraints = [
            emergencyContactsLabel.topAnchor.constraint(
                equalTo: progressBarView.bottomAnchor, constant: 15),
            emergencyContactsLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
        ]
        
        //Main Emergency Contacts
        if emergencyContactsStackView.arrangedSubviews.isEmpty {
            emergencyContactsStackView.addArrangedSubview(createEmergencyContactTextField())
            emergencyContactsStackView.addArrangedSubview(createEmergencyContactTextField())
        }

        NSLayoutConstraint.activate(emergencyContactsLabelConstraints)

        //Emergency Contacts StackView
        let emergencyContactsStackViewConstraints = [
            emergencyContactsStackView.topAnchor.constraint(
                equalTo: emergencyContactsLabel.bottomAnchor, constant: 10),
            emergencyContactsStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            emergencyContactsStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
        ]

        NSLayoutConstraint.activate(emergencyContactsStackViewConstraints)

        //Add Contact Button Constraints
        let addContactButtonConstraints = [
            addContactButton.topAnchor.constraint(
                equalTo: emergencyContactsStackView.bottomAnchor, constant: 10),
            addContactButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            addContactButton.heightAnchor.constraint(equalToConstant: 40),
            addContactButton.widthAnchor.constraint(equalToConstant: 150),
        ]

        NSLayoutConstraint.activate(addContactButtonConstraints)


        //Create Account Button
        navigationButtons.nextButton.setTitle("Create account", for: .normal)

        //Navigation StackView Constraints
        let navgationButtonsStackViewConstraints = [
            navigationButtons.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            navigationButtons.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            navigationButtons.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            navigationButtons.heightAnchor.constraint(equalToConstant: 50),
        ]

        NSLayoutConstraint.activate(navgationButtonsStackViewConstraints)

        //Buttons Functions
        // Remove any existing targets before adding a new one
        addContactButton.removeTarget(nil, action: nil, for: .allEvents)
        navigationButtons.backButton.removeTarget(nil, action: nil, for: .allEvents)
        navigationButtons.nextButton.removeTarget(nil, action: nil, for: .allEvents)

        //Adding Button Functions
        addContactButton.addTarget(self, action: #selector(addEmergencyContactField), for: .touchUpInside)
        navigationButtons.nextButton.addTarget(
            self, action: #selector(createAccountButtonTapped),
            for: .touchUpInside)
        navigationButtons.backButton.addTarget(
            self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
}

extension CreateAccountStep4ViewController {
    
    private func createEmergencyContactTextField() -> UITextField {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter emergency contact", attributes: [
            NSAttributedString.Key.foregroundColor : UIColor.gray
        ])
        textField.keyboardType = .phonePad
        textField.backgroundColor = UIColor(named: "signUpTextFieldBackgroundColor")
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.textColor = .white

        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        textField.leftView = padding
        textField.leftViewMode = .always

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        print("Ana raga3t textField gdeeda")

        return textField
    }

}

//MARK: - Preview
//#if DEBUG
//#Preview("Sign Up 4"){
//    CreateAccountStep4ViewController()
//}
//#endif
