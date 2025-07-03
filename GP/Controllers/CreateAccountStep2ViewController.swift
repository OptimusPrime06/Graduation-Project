//
//  CreateAccountStep3ViewController.swift
//  GP
//
//  Created by Gulliver Raed on 3/25/25.
//

import UIKit

private let backgroundImage = BackgroundImageView()

private let createAccountLabel = StepNumberLabel(stepNumber: 2)

private let progressBarView: SegmentedBarView = {
    
    let progressBarView = SegmentedBarView()
    let colors = [
        UIColor(named: Constants.previousPageColor)!,
        UIColor(named: Constants.currentPageColor)!,
        UIColor(named: Constants.nextPageColor)!
    ]
    let progressViewModel = SegmentedBarView.Model(
        colors: colors, spacing: 12
    )
    progressBarView.setModel(progressViewModel)
    
    progressBarView.translatesAutoresizingMaskIntoConstraints = false
    
    return progressBarView
}()

private let selectDiseasesLabel: UILabel = {
    
    let label = UILabel()
    label.text = "Select from these choronic diseases if you have any ( tap on disease to mark it )"
    label.textColor = .white
    label.font = .systemFont(ofSize: 18)
    label.numberOfLines = 3
    
    label.translatesAutoresizingMaskIntoConstraints = false
    
    return label
}()

private var selectedConditions: Set<String> = []

private let chronicDiseasesTableView: UITableView = {
    let tableView = UITableView()
    tableView.layer.borderWidth = 2
    tableView.layer.borderColor = UIColor.gray.cgColor
    tableView.layer.cornerRadius = 5
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.allowsMultipleSelection = true
    
    tableView.translatesAutoresizingMaskIntoConstraints = false
    
    return tableView
}()

private let otherDiseases: UITextView = {
    
    let textView = UITextView()
    textView.text = "Other"
    textView.textColor = .gray
    textView.backgroundColor = UIColor(named: "signUpTextFieldBackgroundColor")
    textView.layer.cornerRadius = 8
    textView.layer.borderWidth = 2
    textView.layer.borderColor = UIColor.gray.cgColor
    textView.textColor = .white
    textView.font = .systemFont(ofSize: 16)
    textView.textContainerInset = UIEdgeInsets(
        top: 15, left: 15, bottom: 10, right: 15)
    
    textView.translatesAutoresizingMaskIntoConstraints = false
    
    return textView
}()

private let chooseAlertLabel: UILabel = {
    let label = UILabel()
    label.text = "Prefered alert type (you can choose both)"
    label.textColor = .white
    label.font = .systemFont(ofSize: 16)
    label.numberOfLines = 0
    
    label.translatesAutoresizingMaskIntoConstraints = false
    
    return label
}()

private let alertStackView = AlertTypesStackView()

private let navigationButtons = NavigationButtons()

class CreateAccountStep2ViewController: UIViewController {
    
    var step2UserModel : UserModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - Disabiling the Navigation Bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        tableViewSetUp()
        textViewSetUp()
        UISetUp()
    }
    
    @objc func nextButtonTapped() {
        // 1. Set selected conditions
        let chronicConditions = Array(selectedConditions)
        step2UserModel.setConditions(chronicConditions)
        
        // 2. Set "other" conditions if user added anything manually
        let otherText = otherDiseases.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if otherText != "" && otherText != "Other" {
            step2UserModel.setOtherConditions(otherText)
        } else {
            step2UserModel.setOtherConditions("")
        }
        
        // 3. Set preferred alert types
        let selectedAlertTypes = alertStackView.getSelectedAlertTypes() // Make sure this method exists
        step2UserModel.setPreferredAlerts(selectedAlertTypes)
        
        // 4. Go to next screen
        let vc = CreateAccountStep3ViewController()
        vc.step3UserModel = self.step2UserModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension CreateAccountStep2ViewController {
    
    private func UISetUp() {
        
        view.addSubview(backgroundImage)
        view.addSubview(createAccountLabel)
        view.addSubview(progressBarView)
        view.addSubview(selectDiseasesLabel)
        view.addSubview(chronicDiseasesTableView)
        view.addSubview(otherDiseases)
        view.addSubview(chooseAlertLabel)
        view.addSubview(alertStackView)
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
        
        //Select Diseases Label Constraints
        let selectDiseasesLabelConstraints = [
            selectDiseasesLabel.topAnchor.constraint(
                equalTo: progressBarView.bottomAnchor, constant: 5),
            selectDiseasesLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            selectDiseasesLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
        ]
        
        NSLayoutConstraint.activate(selectDiseasesLabelConstraints)
        
        //Choronic Diseases TableView Constraints
        let chronicDiseasesTableViewConstraints = [
            chronicDiseasesTableView.topAnchor.constraint(
                equalTo: selectDiseasesLabel.bottomAnchor, constant: 10),
            chronicDiseasesTableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            chronicDiseasesTableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            chronicDiseasesTableView.heightAnchor.constraint(
                equalToConstant: 310),
        ]
        
        NSLayoutConstraint.activate(chronicDiseasesTableViewConstraints)
        
        //Other Diseases TextField
        let otherDiseasesTextFieldConstraint = [
            otherDiseases.topAnchor.constraint(
                equalTo: chronicDiseasesTableView.bottomAnchor, constant: 15),
            otherDiseases.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            otherDiseases.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            otherDiseases.heightAnchor.constraint(equalToConstant: 70),
        ]
        
        NSLayoutConstraint.activate(otherDiseasesTextFieldConstraint)
        
        //Choose Alert Label Constraints
        let chooseAlertLabelConstraints = [
            chooseAlertLabel.topAnchor.constraint(
                equalTo: otherDiseases.bottomAnchor, constant: 15),
            chooseAlertLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            chooseAlertLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            chooseAlertLabel.heightAnchor.constraint(equalToConstant: 20),
        ]
        
        NSLayoutConstraint.activate(chooseAlertLabelConstraints)
        
        //Alert StackView Constraints
        let alertStackViewConstraints = [
            alertStackView.topAnchor.constraint(
                equalTo: chooseAlertLabel.bottomAnchor, constant: 20),
            alertStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: 20),
            alertStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -20),
            alertStackView.heightAnchor.constraint(equalToConstant: 45),
        ]
        
        NSLayoutConstraint.activate(alertStackViewConstraints)
        
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
        
        //Navigation Buttons functions
        // Remove any existing targets before adding a new one
        navigationButtons.backButton.removeTarget(nil, action: nil, for: .allEvents)
        navigationButtons.nextButton.removeTarget(nil, action: nil, for: .allEvents)
        //Adding Button Functions
        navigationButtons.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        navigationButtons.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
    }
}

extension CreateAccountStep2ViewController: UITableViewDelegate,
                                            UITableViewDataSource
{
    
    private func tableViewSetUp() {
        chronicDiseasesTableView.delegate = self
        chronicDiseasesTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
    -> Int
    {
        Constants.conditions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell", for: indexPath)
        let condition = Constants.conditions[indexPath.row]
        cell.accessoryType =
        selectedConditions.contains(condition) ? .checkmark : .none
        cell.textLabel?.textColor = .white
        cell.backgroundColor = UIColor(named: Constants.signUpTextFieldsBackgroundColor)
        cell.textLabel?.font = .systemFont(ofSize: 14)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = condition
        return cell
    }
    
    func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: IndexPath
    ) {
        let condition = Constants.conditions[indexPath.row]
        if selectedConditions.contains(condition) {
            selectedConditions.remove(condition)
        } else {
            selectedConditions.insert(condition)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}

extension CreateAccountStep2ViewController: UITextViewDelegate {
    
    private func textViewSetUp() {
        otherDiseases.delegate = self
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Other" {
            textView.text = ""
        }
        textView.textColor = .white
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        {
            textView.text = "Other"
            textView.textColor = UIColor.gray  // Restore placeholder color
        }
    }
}
