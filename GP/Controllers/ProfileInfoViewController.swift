//
//  ProfileInfoViewController.swift
//  GP
//
//  Created by Abdelrahman Kafsher on 10/04/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileInfoViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Profile Details"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let personalInfoCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let medicalInfoCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let contactInfoCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Data Properties
    private var userInfo: [String: Any] = [:]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
        loadUserInfo()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        // Background
        let backgroundImage = UIImageView()
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.image = UIImage(named: "backgroundImage")
        backgroundImage.contentMode = .scaleAspectFill
        view.addSubview(backgroundImage)
        
        // Add main components
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(personalInfoCard)
        contentView.addSubview(medicalInfoCard)
        contentView.addSubview(contactInfoCard)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            // Background
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Personal Info Card
            personalInfoCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            personalInfoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            personalInfoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Medical Info Card
            medicalInfoCard.topAnchor.constraint(equalTo: personalInfoCard.bottomAnchor, constant: 20),
            medicalInfoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            medicalInfoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Contact Info Card
            contactInfoCard.topAnchor.constraint(equalTo: medicalInfoCard.bottomAnchor, constant: 20),
            contactInfoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contactInfoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contactInfoCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Activity Indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigation() {
        navigationItem.title = "Profile Information"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        let closeButton = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        closeButton.tintColor = .white
        navigationItem.rightBarButtonItem = closeButton
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Data Loading
    
    private func loadUserInfo() {
        activityIndicator.startAnimating()
        
        guard let user = Auth.auth().currentUser else {
            showAlert(title: "Error", message: "User not signed in.")
            activityIndicator.stopAnimating()
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                
                guard let data = snapshot?.data() else {
                    self.showAlert(title: "Error", message: "Failed to load user data.")
                    return
                }
                
                self.userInfo = data
                self.populateCards()
            }
        }
    }
    
    // MARK: - UI Population
    
    private func populateCards() {
        populatePersonalInfoCard()
        populateMedicalInfoCard()
        populateContactInfoCard()
    }
    
    private func populatePersonalInfoCard() {
        let stackView = createCardStackView(title: "👤 Personal Information")
        
        let name = userInfo["name"] as? String ?? "Not provided"
        let email = userInfo["email"] as? String ?? "Not provided"
        
        // Try different possible age field names
        var age = "Not provided"
        if let ageString = userInfo["age"] as? String {
            age = ageString
        } else if let ageInt = userInfo["age"] as? Int {
            age = "\(ageInt)"
        } else if let ageString = userInfo["Age"] as? String {
            age = ageString
        } else if let selectedAge = userInfo["selectedAge"] as? String {
            age = selectedAge
        }
        
        let gender = userInfo["gender"] as? String ?? "Not provided"
        
        // Try different possible driving experience field names
        var drivingExperience = "Not provided"
        if let experienceString = userInfo["experience"] as? String {
            drivingExperience = experienceString
        } else if let experienceInt = userInfo["experience"] as? Int {
            drivingExperience = "\(experienceInt)"
        } else if let experienceString = userInfo["drivingExperience"] as? String {
            drivingExperience = experienceString
        } else if let experienceString = userInfo["yearsOfDriving"] as? String {
            drivingExperience = experienceString
        } else if let experienceString = userInfo["selectedDrivingExperience"] as? String {
            drivingExperience = experienceString
        } else if let experienceInt = userInfo["drivingExperience"] as? Int {
            drivingExperience = "\(experienceInt)"
        }
        
        addInfoRow(to: stackView, label: "Name:", value: name)
        addInfoRow(to: stackView, label: "Email:", value: email)
        addInfoRow(to: stackView, label: "Age:", value: age)
        addInfoRow(to: stackView, label: "Gender:", value: gender)
        addInfoRow(to: stackView, label: "Years of Driving:", value: drivingExperience)
        
        personalInfoCard.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: personalInfoCard.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: personalInfoCard.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: personalInfoCard.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: personalInfoCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func populateMedicalInfoCard() {
        let stackView = createCardStackView(title: "🏥 Medical Information")
        
        let conditions = userInfo["conditions"] as? [String] ?? []
        let conditionsText = conditions.isEmpty ? "None reported" : conditions.joined(separator: ", ")
        
        // Try different possible other conditions field names
        var otherConditions = "Not provided"
        if let otherConditionsString = userInfo["otherConditions"] as? String,
           !otherConditionsString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            otherConditions = otherConditionsString
        } else if let otherConditionsString = userInfo["additionalConditions"] as? String,
                  !otherConditionsString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            otherConditions = otherConditionsString
        } else if let otherConditionsString = userInfo["customConditions"] as? String,
                  !otherConditionsString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            otherConditions = otherConditionsString
        } else if let otherConditionsString = userInfo["other"] as? String,
                  !otherConditionsString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            otherConditions = otherConditionsString
        }
        
        addInfoRow(to: stackView, label: "Medical Conditions:", value: conditionsText)
        addInfoRow(to: stackView, label: "Other Conditions:", value: otherConditions)
        
        medicalInfoCard.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: medicalInfoCard.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: medicalInfoCard.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: medicalInfoCard.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: medicalInfoCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func populateContactInfoCard() {
        let stackView = createCardStackView(title: "📞 Emergency Contacts")
        
        // Read from emergencyContacts array
        if let emergencyContacts = userInfo["emergencyContacts"] as? [[String: Any]],
           !emergencyContacts.isEmpty {
            
            for (index, contact) in emergencyContacts.enumerated() {
                let contactName = contact["name"] as? String ?? "No Name"
                let contactPhone = contact["phone"] as? String ?? "No Phone"
                
                addContactRow(to: stackView, name: contactName, phone: contactPhone, index: index + 1)
                
                if index < emergencyContacts.count - 1 {
                    addSpacer(to: stackView)
                }
            }
        } else {
            let noContactsLabel = UILabel()
            noContactsLabel.text = "No emergency contacts found"
            noContactsLabel.textColor = .lightGray
            noContactsLabel.font = UIFont.systemFont(ofSize: 16)
            stackView.addArrangedSubview(noContactsLabel)
        }
        
        contactInfoCard.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contactInfoCard.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contactInfoCard.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contactInfoCard.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contactInfoCard.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Helper Methods
    
    private func createCardStackView(title: String) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        
        stackView.addArrangedSubview(titleLabel)
        
        return stackView
    }
    
    private func addInfoRow(to stackView: UIStackView, label: String, value: String) {
        let containerView = UIView()
        
        let labelView = UILabel()
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.text = label
        labelView.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        labelView.textColor = .lightGray
        labelView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let valueView = UILabel()
        valueView.translatesAutoresizingMaskIntoConstraints = false
        valueView.text = value
        valueView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        valueView.textColor = .white
        valueView.numberOfLines = 0
        valueView.textAlignment = .right
        valueView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        containerView.addSubview(labelView)
        containerView.addSubview(valueView)
        
        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: containerView.topAnchor),
            labelView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            labelView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor),
            labelView.trailingAnchor.constraint(lessThanOrEqualTo: valueView.leadingAnchor, constant: -8),
            labelView.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            valueView.topAnchor.constraint(equalTo: containerView.topAnchor),
            valueView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            valueView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        stackView.addArrangedSubview(containerView)
    }
    
    private func addSectionHeader(to stackView: UIStackView, title: String) {
        let headerLabel = UILabel()
        headerLabel.text = title
        headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        headerLabel.textColor = .systemBlue
        stackView.addArrangedSubview(headerLabel)
    }
    
    private func addContactRow(to stackView: UIStackView, name: String, phone: String, index: Int) {
        let containerView = UIView()
        
        let contactLabel = UILabel()
        contactLabel.translatesAutoresizingMaskIntoConstraints = false
        contactLabel.text = "\(name) - \(phone)"
        contactLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        contactLabel.textColor = .white
        contactLabel.numberOfLines = 0
        
        let numberLabel = UILabel()
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.text = "\(index)"
        numberLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        numberLabel.textColor = .systemBlue
        numberLabel.textAlignment = .center
        numberLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        numberLabel.layer.cornerRadius = 12
        numberLabel.clipsToBounds = true
        numberLabel.widthAnchor.constraint(equalToConstant: 24).isActive = true
        numberLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        containerView.addSubview(numberLabel)
        containerView.addSubview(contactLabel)
        
        NSLayoutConstraint.activate([
            numberLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            contactLabel.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: 12),
            contactLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            contactLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            contactLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        stackView.addArrangedSubview(containerView)
    }
    

    
    private func addSpacer(to stackView: UIStackView) {
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
        stackView.addArrangedSubview(spacer)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 