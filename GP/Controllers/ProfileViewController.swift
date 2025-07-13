//
//  ProfileViewController.swift
//  GP
//
//  Created by Abdelrahman Kafsher on 10/04/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CryptoKit

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
        label.text = ""
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
        label.text = ""
        label.isAccessibilityElement = true
        label.accessibilityLabel = "User Email"
        return label
    }()
    
    private let editNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("👤 Edit Name", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.isAccessibilityElement = true
        button.accessibilityLabel = "Edit Name Button"
        return button
    }()
    
    private let editEmailButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("✉️ Edit Email", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.isAccessibilityElement = true
        button.accessibilityLabel = "Edit Email Button"
        return button
    }()
    
    private let changePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("🔒 Change Password", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.isAccessibilityElement = true
        button.accessibilityLabel = "Change Password Button"
        return button
    }()
    
    private let profileDetailsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "person.text.rectangle"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 20
        button.isAccessibilityElement = true
        button.accessibilityLabel = "Profile Details Button"
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
    
    private let infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 20
        button.isAccessibilityElement = true
        button.accessibilityLabel = "Information Button"
        return button
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImageView()
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.image = UIImage(named: "backgroundImage")
        backgroundImage.contentMode = .scaleAspectFill
        view.addSubview(backgroundImage)
        
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(editNameButton)
        view.addSubview(editEmailButton)
        view.addSubview(changePasswordButton)
        view.addSubview(logoutButton)
        view.addSubview(activityIndicator)
        view.addSubview(profileDetailsButton)
        view.addSubview(infoButton)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        profileImageView.isUserInteractionEnabled = true
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(imageTapGesture)
        
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            editNameButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            editNameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editNameButton.widthAnchor.constraint(equalToConstant: 200),
            editNameButton.heightAnchor.constraint(equalToConstant: 44),
            
            editEmailButton.topAnchor.constraint(equalTo: editNameButton.bottomAnchor, constant: 12),
            editEmailButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editEmailButton.widthAnchor.constraint(equalToConstant: 200),
            editEmailButton.heightAnchor.constraint(equalToConstant: 44),
            
            changePasswordButton.topAnchor.constraint(equalTo: editEmailButton.bottomAnchor, constant: 12),
            changePasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changePasswordButton.widthAnchor.constraint(equalToConstant: 200),
            changePasswordButton.heightAnchor.constraint(equalToConstant: 44),
            
            logoutButton.topAnchor.constraint(equalTo: changePasswordButton.bottomAnchor, constant: 20),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            profileDetailsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            profileDetailsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            profileDetailsButton.widthAnchor.constraint(equalToConstant: 40),
            profileDetailsButton.heightAnchor.constraint(equalToConstant: 40),
            
            infoButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            infoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            infoButton.widthAnchor.constraint(equalToConstant: 40),
            infoButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        editNameButton.addTarget(self, action: #selector(editNameTapped), for: .touchUpInside)
        editEmailButton.addTarget(self, action: #selector(editEmailTapped), for: .touchUpInside)
        changePasswordButton.addTarget(self, action: #selector(changePasswordTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        profileDetailsButton.addTarget(self, action: #selector(viewProfileInfoTapped), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        
        loadLocalProfileImage()
        loadUserData()
        
        // Setup gradient layers after view loads
        setupButtonGradients()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update gradient frames when layout changes
        updateButtonGradients()
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            do {
                try Auth.auth().signOut()
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    sceneDelegate.showLoginScreen()
                }
            } catch let signOutError as NSError {
                self.showAlert(title: "Error", message: signOutError.localizedDescription)
            }
        })
        present(alert, animated: true)
    }
    
    @objc private func infoButtonTapped() {
        let infoViewController = InformationViewController()
        let navigationController = UINavigationController(rootViewController: infoViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    @objc private func profileImageTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let selectedImage = (info[.editedImage] ?? info[.originalImage]) as? UIImage else {
            return
        }
        
        profileImageView.image = selectedImage
        saveProfileImageLocally(selectedImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
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
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func editNameTapped() {
        let alert = UIAlertController(title: "Edit Name", message: "Enter your new name.", preferredStyle: .alert)
        alert.addTextField { [weak self] textField in
            textField.placeholder = "New Name"
            textField.text = self?.nameLabel.text
            textField.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let newName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !newName.isEmpty,
                  newName.count >= 2 else {
                self.showAlert(title: "Invalid Name", message: "Please enter a valid name with at least 2 characters.")
                return
            }
            self.updateName(newName)
        })
        present(alert, animated: true)
    }
    
    @objc private func editEmailTapped() {
        let alert = UIAlertController(title: "Edit Email", message: "Enter your new email address.", preferredStyle: .alert)
        alert.addTextField { [weak self] textField in
            textField.placeholder = "New Email"
            textField.text = self?.emailLabel.text
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
    
    @objc private func changePasswordTapped() {
        let alert = UIAlertController(title: "Change Password", message: "Enter your current and new password.", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Current Password"
            textField.isSecureTextEntry = true
        }
        
        alert.addTextField { textField in
            textField.placeholder = "New Password"
            textField.isSecureTextEntry = true
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Confirm New Password"
            textField.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Change", style: .default) { [weak self] _ in
            guard let self = self else { return }
            guard let currentPassword = alert.textFields?[0].text,
                  let newPassword = alert.textFields?[1].text,
                  let confirmPassword = alert.textFields?[2].text else { return }
            
            if newPassword != confirmPassword {
                self.showAlert(title: "Password Mismatch", message: "New passwords don't match.")
                return
            }
            
            if newPassword.count < 6 {
                self.showAlert(title: "Weak Password", message: "Password must be at least 6 characters long.")
                return
            }
            
            self.changePassword(currentPassword: currentPassword, newPassword: newPassword)
        })
        present(alert, animated: true)
    }
    
    @objc private func viewProfileInfoTapped() {
        let profileInfoVC = ProfileInfoViewController()
        let navigationController = UINavigationController(rootViewController: profileInfoVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
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
                
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).updateData([
                    "email": newEmail
                ]) { error in
                    if let error = error {
                        self.showAlert(title: "Firestore Error", message: error.localizedDescription)
                        return
                    }
                    self.emailLabel.text = newEmail
                    self.showAlert(title: "Email Change Pending", message: "A verification link was sent to your new email. Once you verify it, your email will be updated.")
                }
            }
        }
    }
    
    private func updateName(_ newName: String) {
        setLoading(true)
        guard let user = Auth.auth().currentUser else {
            showAlert(title: "Error", message: "User not signed in.")
            setLoading(false)
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).updateData([
            "name": newName
        ]) { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.setLoading(false)
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                self.nameLabel.text = newName
                self.showAlert(title: "Success", message: "Name updated successfully!")
            }
        }
    }
    
    private func changePassword(currentPassword: String, newPassword: String) {
        setLoading(true)
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            showAlert(title: "Error", message: "User not signed in.")
            setLoading(false)
            return
        }
        
        // Reauthenticate user with current password
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { [weak self] _, error in
            guard let self = self else { return }
            if let error = error {
                DispatchQueue.main.async {
                    self.setLoading(false)
                    self.showAlert(title: "Authentication Failed", message: "Current password is incorrect.")
                }
                return
            }
            
            // Update password
            user.updatePassword(to: newPassword) { error in
                DispatchQueue.main.async {
                    self.setLoading(false)
                    if let error = error {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                        return
                    }
                    self.showAlert(title: "Success", message: "Password changed successfully!")
                }
            }
        }
    }

    private func setLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            if loading {
                self.activityIndicator.startAnimating()
                // Disable all buttons with visual feedback
                self.setButtonsEnabled(false)
                self.view.alpha = 0.7
            } else {
                self.activityIndicator.stopAnimating()
                // Re-enable all buttons
                self.setButtonsEnabled(true)
                
                // Smooth animation back to normal state
                UIView.animate(withDuration: 0.3) {
                    self.view.alpha = 1.0
                }
            }
        }
    }
    
    private func setButtonsEnabled(_ enabled: Bool) {
        editNameButton.isEnabled = enabled
        editEmailButton.isEnabled = enabled
        changePasswordButton.isEnabled = enabled
        profileDetailsButton.isEnabled = enabled
        logoutButton.isEnabled = enabled
        
        // Visual feedback for disabled state
        let alpha: CGFloat = enabled ? 1.0 : 0.6
        editNameButton.alpha = alpha
        editEmailButton.alpha = alpha
        changePasswordButton.alpha = alpha
        profileDetailsButton.alpha = alpha
        logoutButton.alpha = alpha
    }
    
    private func saveProfileImageLocally(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let fileURL = getProfileImageFileURL()
        do {
            try data.write(to: fileURL)
            print("✅ Profile image saved locally.")
        } catch {
            print("❌ Error saving image: \(error)")
        }
    }
    
    private func loadLocalProfileImage() {
        let fileURL = getProfileImageFileURL()
        if FileManager.default.fileExists(atPath: fileURL.path),
           let imageData = try? Data(contentsOf: fileURL),
           let image = UIImage(data: imageData) {
            profileImageView.image = image
        }
    }
    
    private func getProfileImageFileURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("profileImage.jpg")
    }
    
    private func setupButtonGradients() {
        setupButtonGradient(for: editNameButton, colors: [UIColor.systemGreen.cgColor, UIColor.systemTeal.cgColor], shadowColor: UIColor.systemGreen.cgColor)
        setupButtonGradient(for: editEmailButton, colors: [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor], shadowColor: UIColor.systemBlue.cgColor)
        setupButtonGradient(for: changePasswordButton, colors: [UIColor.systemOrange.cgColor, UIColor.systemRed.cgColor], shadowColor: UIColor.systemOrange.cgColor)
    }
    
    private func setupButtonGradient(for button: UIButton, colors: [CGColor], shadowColor: CGColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 12
        
        // Remove existing gradient layers
        button.layer.sublayers?.removeAll { $0 is CAGradientLayer }
        
        button.layer.insertSublayer(gradientLayer, at: 0)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = shadowColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
    }
    
    private func updateButtonGradients() {
        updateButtonGradientFrame(for: editNameButton)
        updateButtonGradientFrame(for: editEmailButton)
        updateButtonGradientFrame(for: changePasswordButton)
    }
    
    private func updateButtonGradientFrame(for button: UIButton) {
        if let gradientLayer = button.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradientLayer.frame = button.bounds
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    func sha256() -> String {
        let hash = SHA256.hash(data: self.data(using: .utf8) ?? Data())
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}

