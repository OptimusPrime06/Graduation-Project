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
        
        let backgroundImage = UIImageView()
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.image = UIImage(named: "backgroundImage")
        backgroundImage.contentMode = .scaleAspectFill
        view.addSubview(backgroundImage)
        
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(editEmailButton)
        view.addSubview(logoutButton)
        view.addSubview(activityIndicator)
        
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
            
            editEmailButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            editEmailButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editEmailButton.widthAnchor.constraint(equalToConstant: 200),
            editEmailButton.heightAnchor.constraint(equalToConstant: 50),
            
            logoutButton.topAnchor.constraint(equalTo: editEmailButton.bottomAnchor, constant: 20),
            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 200),
            logoutButton.heightAnchor.constraint(equalToConstant: 50),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        editEmailButton.addTarget(self, action: #selector(editEmailTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        
        loadLocalProfileImage()
        loadUserData()
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
