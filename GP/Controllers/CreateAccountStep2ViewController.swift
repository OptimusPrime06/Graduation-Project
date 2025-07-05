//
//  CreateAccountStep2ViewController.swift
//  GP
//
//  Created by Gulliver Raed on 3/25/25.
//

import UIKit

private let scrollView = UIScrollView()
private let contentView = UIView()
private let backgroundImage = BackgroundImageView()
private let createAccountLabel = StepNumberLabel(stepNumber: 2)

private let progressBarView: SegmentedBarView = {
    let progressBarView = SegmentedBarView()
    let colors = [
        UIColor(named: Constants.previousPageColor)!,
        UIColor(named: Constants.currentPageColor)!,
        UIColor(named: Constants.nextPageColor)!
    ]
    let progressViewModel = SegmentedBarView.Model(colors: colors, spacing: 12)
    progressBarView.setModel(progressViewModel)
    progressBarView.translatesAutoresizingMaskIntoConstraints = false
    return progressBarView
}()

private let selectDiseasesLabel: UILabel = {
    let label = UILabel()
    label.text = "Select from these chronic diseases if you have any (tap on disease to mark it)"
    label.textColor = .white
    label.font = .systemFont(ofSize: 18)
    label.numberOfLines = 3
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
}()

private let chronicDiseasesTableView: UITableView = {
    let tableView = UITableView()
    tableView.layer.borderWidth = 2
    tableView.layer.borderColor = UIColor.gray.cgColor
    tableView.layer.cornerRadius = 5
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
    textView.font = .systemFont(ofSize: 16)
    textView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 10, right: 15)
    textView.translatesAutoresizingMaskIntoConstraints = false
    return textView
}()

private let navigationButtons = NavigationButtons()

class CreateAccountStep2ViewController: UIViewController {
    
    var step2UserModel: UserModel!
    private var selectedConditions: Set<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        
        chronicDiseasesTableView.delegate = self
        chronicDiseasesTableView.dataSource = self
        chronicDiseasesTableView.allowsMultipleSelection = true
        
        otherDiseases.delegate = self
        
        setupUI()
        setupKeyboardNotifications()
        scrollView.delaysContentTouches = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func nextButtonTapped() {
        let chronicConditions = Array(selectedConditions)
        step2UserModel.setConditions(chronicConditions)
        
        let otherText = otherDiseases.text.trimmingCharacters(in: .whitespacesAndNewlines)
        step2UserModel.setOtherConditions((otherText != "" && otherText != "Other") ? otherText : "")
        
        let vc = CreateAccountStep3ViewController()
        vc.step3UserModel = self.step2UserModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentInset.bottom = keyboardSize.height + 20
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = .zero
    }
    
    private func setupUI() {
        view.addSubview(backgroundImage)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(createAccountLabel)
        contentView.addSubview(progressBarView)
        contentView.addSubview(selectDiseasesLabel)
        contentView.addSubview(chronicDiseasesTableView)
        contentView.addSubview(otherDiseases)
        contentView.addSubview(navigationButtons)
        
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        createAccountLabel.translatesAutoresizingMaskIntoConstraints = false
        navigationButtons.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            createAccountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            createAccountLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            createAccountLabel.heightAnchor.constraint(equalToConstant: 40),
            
            progressBarView.topAnchor.constraint(equalTo: createAccountLabel.bottomAnchor, constant: 20),
            progressBarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            progressBarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            progressBarView.heightAnchor.constraint(equalToConstant: 20),
            
            selectDiseasesLabel.topAnchor.constraint(equalTo: progressBarView.bottomAnchor, constant: 10),
            selectDiseasesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            selectDiseasesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            chronicDiseasesTableView.topAnchor.constraint(equalTo: selectDiseasesLabel.bottomAnchor, constant: 10),
            chronicDiseasesTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            chronicDiseasesTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            chronicDiseasesTableView.heightAnchor.constraint(equalToConstant: 310),
            
            otherDiseases.topAnchor.constraint(equalTo: chronicDiseasesTableView.bottomAnchor, constant: 15),
            otherDiseases.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            otherDiseases.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            otherDiseases.heightAnchor.constraint(equalToConstant: 70),
            
            navigationButtons.topAnchor.constraint(equalTo: otherDiseases.bottomAnchor, constant: 30),
            navigationButtons.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            navigationButtons.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            navigationButtons.heightAnchor.constraint(equalToConstant: 50),
            navigationButtons.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
        
        navigationButtons.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        navigationButtons.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
}

// MARK: - UITableView Delegate/DataSource
extension CreateAccountStep2ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.conditions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let condition = Constants.conditions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = condition
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .systemFont(ofSize: 14)
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = UIColor(named: Constants.signUpTextFieldsBackgroundColor)
        cell.accessoryType = selectedConditions.contains(condition) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let condition = Constants.conditions[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        
        if selectedConditions.contains(condition) {
            selectedConditions.remove(condition)
            cell?.accessoryType = .none
        } else {
            selectedConditions.insert(condition)
            cell?.accessoryType = .checkmark
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - UITextView Delegate
extension CreateAccountStep2ViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Other" {
            textView.text = ""
            textView.textColor = .white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = "Other"
            textView.textColor = .gray
        }
    }
}
