//
//  CreateAccountStep4ViewController.swift
//  GP
//
//  Created by Gulliver Raed on 3/29/25.
//

import UIKit
import Contacts
import ContactsUI

//MARK: - Declaring UI components

private let backgroundImage = BackgroundImageView()

private let createAccountLabel = StepNumberLabel(stepNumber: 3)

private let progressBarView: SegmentedBarView = {

    let progressBarView = SegmentedBarView()
    let colors = [
        UIColor(named: Constants.previousPageColor)!,
        UIColor(named: Constants.previousPageColor)!,
        UIColor(named: Constants.currentPageColor)!
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
    label.text = "Add An Emergency Contacts (At least 2)"
    label.textColor = .white
    label.font = .systemFont(ofSize: 18, weight: .bold)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
}()

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
    button.backgroundColor = UIColor(named: Constants.nextButtonColor)
    button.layer.cornerRadius = 8

    button.translatesAutoresizingMaskIntoConstraints = false

    return button
}()

private let navigationButtons = NavigationButtons()

class CreateAccountStep3ViewController: UIViewController, CNContactPickerDelegate {
    
    var step3UserModel : UserModel!
    
    private var emergencyContacts: [[String: String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - Disabiling the Navigation Bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        UISetUp()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        let handle = Auth.auth().addStateDidChangeListener { auth, user in
//          // ...
//        }
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        Auth.auth().removeStateDidChangeListener(handle!)
//    }

    @objc func addEmergencyContactField() {
        requestContactsAccess()
    }

    @objc func createAccountButtonTapped() {
        if emergencyContacts.count < 2 {
            let alert = UIAlertController(title: "At least 2 contacts required", message: "Please add at least 2 emergency contacts before creating your account.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        // Save contacts to user model or Firestore as needed
        _ = CreateAccountViewModel(with: step3UserModel, delegate: self)
    }

    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func requestContactsAccess() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    self?.showContactPicker()
                } else {
                    self?.showContactsPermissionAlert()
                }
            }
        }
    }

    private func showContactPicker() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
        present(contactPicker, animated: true)
    }

    private func showContactsPermissionAlert() {
        let alert = UIAlertController(
            title: "Contacts Access Required",
            message: "Please allow access to your contacts to add emergency contacts.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - CNContactPickerDelegate
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        guard let phoneNumber = contact.phoneNumbers.first?.value.stringValue else { return }
        let contactInfo: [String: String] = [
            "name": "\(contact.givenName) \(contact.familyName)",
            "phone": phoneNumber
        ]
        emergencyContacts.append(contactInfo)
        let label = UILabel()
        label.text = "\(contact.givenName) \(contact.familyName): \(phoneNumber)"
        label.textColor = .white
        label.backgroundColor = UIColor(named: Constants.signUpTextFieldsBackgroundColor)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.heightAnchor.constraint(equalToConstant: 50).isActive = true
        emergencyContactsStackView.addArrangedSubview(label)
    }

    // Helper to get contacts array for saving
    func getEmergencyContactsForSaving() -> [[String: String]] {
        return emergencyContacts
    }
}

extension CreateAccountStep3ViewController {

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
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]

        NSLayoutConstraint.activate(backgroundImageConstraints)

        //Step1 Label
        let setUpLabelConstraints = [
            createAccountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            createAccountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createAccountLabel.heightAnchor.constraint(equalToConstant: 40),
        ]

        NSLayoutConstraint.activate(setUpLabelConstraints)

        //Progress Bar Constraints
        let progressBarConstraints = [
            progressBarView.topAnchor.constraint(equalTo: createAccountLabel.bottomAnchor, constant: 20),
            progressBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressBarView.heightAnchor.constraint(equalToConstant: 20),
        ]

        NSLayoutConstraint.activate(progressBarConstraints)

        //Emergency Contacts Label Constraints
        let emergencyContactsLabelConstraints = [
            emergencyContactsLabel.topAnchor.constraint(equalTo: progressBarView.bottomAnchor, constant: 15),
            emergencyContactsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        ]
        
        NSLayoutConstraint.activate(emergencyContactsLabelConstraints)

        //Emergency Contacts StackView
        let emergencyContactsStackViewConstraints = [
            emergencyContactsStackView.topAnchor.constraint(equalTo: emergencyContactsLabel.bottomAnchor, constant: 10),
            emergencyContactsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emergencyContactsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ]

        NSLayoutConstraint.activate(emergencyContactsStackViewConstraints)

        //Add Contact Button Constraints
        let addContactButtonConstraints = [
            addContactButton.topAnchor.constraint(equalTo: emergencyContactsStackView.bottomAnchor, constant: 10),
            addContactButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addContactButton.heightAnchor.constraint(equalToConstant: 40),
            addContactButton.widthAnchor.constraint(equalToConstant: 150),
        ]

        NSLayoutConstraint.activate(addContactButtonConstraints)


        //Create Account Button
        navigationButtons.nextButton.setTitle("Create account", for: .normal)

        //Navigation StackView Constraints
        let navgationButtonsStackViewConstraints = [
            navigationButtons.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            navigationButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            navigationButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            navigationButtons.heightAnchor.constraint(equalToConstant: 50),
        ]

        NSLayoutConstraint.activate(navgationButtonsStackViewConstraints)

        //Remove any pre-existing contact fields or labels
        for view in emergencyContactsStackView.arrangedSubviews {
            emergencyContactsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        //Buttons Functions
        addContactButton.removeTarget(nil, action: nil, for: .allEvents)
        navigationButtons.backButton.removeTarget(nil, action: nil, for: .allEvents)
        navigationButtons.nextButton.removeTarget(nil, action: nil, for: .allEvents)

        //Adding Button Functions
        addContactButton.addTarget(self, action: #selector(addEmergencyContactField), for: .touchUpInside)
        navigationButtons.nextButton.addTarget(self, action: #selector(createAccountButtonTapped),for: .touchUpInside)
        navigationButtons.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    private func createEmergencyContactTextField() -> UITextField {
        
        let textField = SignUpTextFields(placeholder: "Enter emergency contact", backgrounColor: Constants.signUpTextFieldsBackgroundColor)
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        return textField
    }
    
}
