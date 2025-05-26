//
//  ProfileViewController.swift
//  GP
//
//  Created by Abdelrahman Kafsher on 10/04/2025.
//

import UIKit
<<<<<<< HEAD

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

=======
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - UI Components
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.systemGray5
        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = "Profile Image"
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.textColor = .white
        label.text = "Name"
        label.isAccessibilityElement = true
        label.accessibilityLabel = "User Name"
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .white
        label.text = "Email"
        label.isAccessibilityElement = true
        label.accessibilityLabel = "User Email"
        return label
    }()
    
    private let editEmailButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Edit Email", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        button.layer.cornerRadius = 8
        button.isAccessibilityElement = true
        button.accessibilityLabel = "Edit Email Button"
        return button
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.isAccessibilityElement = true
        button.accessibilityLabel = "Log Out Button"
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add background image
        let backgroundImage = UIImageView()
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.image = UIImage(named: "backgroundImage")
        backgroundImage.contentMode = .scaleAspectFill
        view.addSubview(backgroundImage)
        
        // Add subviews
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(editEmailButton)
        view.addSubview(logoutButton)
        view.addSubview(activityIndicator)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Background image constraints
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Profile image constraints
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Name label constraints
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Email label constraints
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Edit email button constraints
            editEmailButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            editEmailButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editEmailButton.widthAnchor.constraint(equalToConstant: 200),
            editEmailButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Logout button constraints
            logoutButton.topAnchor.constraint(equalTo: editEmailButton.bottomAnchor, constant: 20),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Button targets
        editEmailButton.addTarget(self, action: #selector(editEmailTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        
        // Make profile image view tappable
        profileImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
        
        // Load user data
        loadUserData()
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            do {
                try Auth.auth().signOut()
                // Navigate to login screen
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    sceneDelegate.showLoginScreen()
                }
            } catch let signOutError as NSError {
                self.showAlert(title: "Error", message: signOutError.localizedDescription)
            }
        })
        
        present(alert, animated: true)
    }
    
    @objc private func profileImageTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let editedImage = info[.editedImage] as? UIImage {
            profileImageView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageView.image = originalImage
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // MARK: - Firebase Data Loading
    
    private func loadUserData() {
        setLoading(true)
        guard let user = Auth.auth().currentUser else {
            showAlert(title: "Error", message: "User not signed in.")
            setLoading(false)
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.setLoading(false)
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                guard let data = snapshot?.data(),
                      let name = data["name"] as? String,
                      let email = data["email"] as? String else {
                    self.showAlert(title: "Error", message: "Failed to load user data.")
                    return
                }
                self.nameLabel.text = name
                self.emailLabel.text = email
            }
        }
    }
    
    // MARK: - Edit Email Functionality
    
    @objc private func editEmailTapped() {
        let alert = UIAlertController(title: "Edit Email", message: "Enter your new email address.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "New Email"
            textField.keyboardType = .emailAddress
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let newEmail = alert.textFields?.first?.text,
                  !newEmail.isEmpty,
                  newEmail.isValidEmail() else {
                self.showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
                return
            }
            self.updateEmail(newEmail)
        })
        present(alert, animated: true)
    }
    
    private func updateEmail(_ newEmail: String) {
        setLoading(true)
        guard let user = Auth.auth().currentUser else {
            showAlert(title: "Error", message: "User not signed in.")
            setLoading(false)
            return
        }
        user.sendEmailVerification(beforeUpdatingEmail: newEmail) { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.setLoading(false)
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                // Update email in Firestore
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).updateData(["email": newEmail]) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.showAlert(title: "Error", message: error.localizedDescription)
                            return
                        }
                        self.emailLabel.text = newEmail
                        self.showAlert(title: "Success", message: "Email updated successfully. Please verify your new email.")
                    }
                }
            }
        }
    }
    
    // MARK: - Alert Helper
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            if loading {
                self.activityIndicator.startAnimating()
                self.editEmailButton.isEnabled = false
                self.logoutButton.isEnabled = false
            } else {
                self.activityIndicator.stopAnimating()
                self.editEmailButton.isEnabled = true
                self.logoutButton.isEnabled = true
            }
        }
    }
}

// MARK: - String Extension for Email Validation

extension String {
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
>>>>>>> origin/main3
}
