//
//  CreateAccountStep1ViewController.swift
//  GP
//
//  Created by Gulliver Raed on 3/7/25.
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
    createAccountLabel.text = "Step 1"
    createAccountLabel.numberOfLines = 0
    createAccountLabel.font = .systemFont(ofSize: 40, weight: .bold)
    createAccountLabel.textColor = .white

    createAccountLabel.translatesAutoresizingMaskIntoConstraints = false

    return createAccountLabel
}()

private let progressBarView: SegmentedBarView = {

    let progressBarView = SegmentedBarView()
    let colors = [
        UIColor(named: "currentPageColor")!,
        UIColor(named: "nextPageColor")!,
        UIColor(named: "nextPageColor")!,
        UIColor(named: "nextPageColor")!
    ]
    let progressViewModel = SegmentedBarView.Model(
        colors: colors, spacing: 12
    )
    progressBarView.setModel(progressViewModel)

    progressBarView.translatesAutoresizingMaskIntoConstraints = false

    return progressBarView
}()

private let nameTextField: UITextField = {

    let nameTextField = UITextField()
    nameTextField.textColor = .white
    nameTextField.attributedPlaceholder = NSAttributedString(
        string: " Name",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
    )
    nameTextField.backgroundColor = UIColor(
        named: "signUpTextFieldBackgroundColor")
    nameTextField.layer.borderWidth = 2
    nameTextField.layer.borderColor = UIColor.gray.cgColor
    nameTextField.layer.cornerRadius = 12
    let padding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
    nameTextField.leftView = padding
    nameTextField.leftViewMode = .always

    nameTextField.translatesAutoresizingMaskIntoConstraints = false

    return nameTextField
}()

private let emailTextField: UITextField = {

    let emailTextField = UITextField()
    emailTextField.textColor = .white
    emailTextField.attributedPlaceholder = NSAttributedString(
        string: " Email",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
    )
    emailTextField.backgroundColor = UIColor(
        named: "signUpTextFieldBackgroundColor")
    emailTextField.layer.borderWidth = 2
    emailTextField.layer.borderColor = UIColor.gray.cgColor
    emailTextField.layer.cornerRadius = 12
    let padding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
    emailTextField.leftView = padding
    emailTextField.leftViewMode = .always

    emailTextField.translatesAutoresizingMaskIntoConstraints = false

    return emailTextField
}()

private let passwordTextField: UITextField = {

    let passwordTextField = UITextField()
    passwordTextField.textColor = .white
    passwordTextField.attributedPlaceholder = NSAttributedString(
        string: "Password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
    )
    passwordTextField.backgroundColor = UIColor(
        named: "signUpTextFieldBackgroundColor")
    passwordTextField.isSecureTextEntry = true
    passwordTextField.layer.borderWidth = 2
    passwordTextField.layer.borderColor = UIColor.gray.cgColor
    passwordTextField.layer.cornerRadius = 12
    let padding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
    passwordTextField.leftView = padding
    passwordTextField.leftViewMode = .always

    passwordTextField.translatesAutoresizingMaskIntoConstraints = false

    return passwordTextField
}()

private let ageTextField: UITextField = {

    let ageTextField = UITextField()
    ageTextField.textColor = .white
    ageTextField.attributedPlaceholder = NSAttributedString(
        string: "Age",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
    )
    ageTextField.backgroundColor = UIColor(
        named: "signUpTextFieldBackgroundColor")
    ageTextField.layer.borderWidth = 2
    ageTextField.layer.borderColor = UIColor.gray.cgColor
    ageTextField.layer.cornerRadius = 12
    let padding = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
    ageTextField.leftView = padding
    ageTextField.leftViewMode = .always

    ageTextField.translatesAutoresizingMaskIntoConstraints = false

    return ageTextField
}()

private let maleGenderButton: UIButton = {

    let maleGenderButton = UIButton()
    maleGenderButton.backgroundColor = UIColor(
        named: "signUpTextFieldBackgroundColor")
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
        named: "signUpTextFieldBackgroundColor")
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

    let driverExperiencDropDownMenu = UIButton(
        configuration: config, primaryAction: nil)
    driverExperiencDropDownMenu.backgroundColor = UIColor(
        named: "signUpTextFieldBackgroundColor")
    driverExperiencDropDownMenu.setTitleColor(.gray, for: .normal)
    driverExperiencDropDownMenu.layer.borderWidth = 2
    driverExperiencDropDownMenu.layer.borderColor = UIColor.gray.cgColor
    driverExperiencDropDownMenu.layer.cornerRadius = 12
    driverExperiencDropDownMenu.contentHorizontalAlignment = .leading

    var menuChildren: [UIMenuElement] = []
    for years in yearsOfExperience {
        menuChildren.append(
            UIAction(title: String(years), handler: actionClosure))
    }
    driverExperiencDropDownMenu.menu = UIMenu(
        options: .displayInline, children: menuChildren)
    driverExperiencDropDownMenu.showsMenuAsPrimaryAction = true
    driverExperiencDropDownMenu.changesSelectionAsPrimaryAction = true

    driverExperiencDropDownMenu.translatesAutoresizingMaskIntoConstraints =
        false

    return driverExperiencDropDownMenu
}()

private let navigationButtons = NavigationButtons()


//MARK: - CreateAccountStep1ViewController Class

class CreateAccountStep1ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - Disabiling the Navigation Bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        UISetUp()
    }
    
    @objc func nextButtonTapped() {
        let vc = CreateAccountStep2ViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func backButtonTapped() {
        let vc = LogInViewController()
        navigationController?.pushViewController(vc, animated: true)
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
    }

}

//MARK: - Preview
//#if DEBUG
//    #Preview("Sign Up 1 View") {
//        CreateAccountStep1ViewController()
//    }
//#endif
