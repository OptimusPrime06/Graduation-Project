//
//  InformationViewController.swift
//  GP
//
//  Created by Abdelrahman Kafsher on 10/04/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class InformationViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["FAQ", "Privacy Policy", "Terms of Service"]
        let control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        control.selectedSegmentTintColor = UIColor.systemBlue
        control.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return control
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor.clear
        return scrollView
    }()
    
    private let contentTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .black
        textView.isEditable = false
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        return textView
    }()
    
    private let deleteAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Delete Account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.isAccessibilityElement = true
        button.accessibilityLabel = "Delete Account Button"
        return button
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupContent()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Information"
        
        // Setup background
        let backgroundImage = UIImageView()
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.image = UIImage(named: "backgroundImage")
        backgroundImage.contentMode = .scaleAspectFill
        view.addSubview(backgroundImage)
        
        // Setup navigation bar
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(dismissViewController)
        )
        
        // Add subviews
        view.addSubview(segmentedControl)
        view.addSubview(deleteAccountButton)
        view.addSubview(scrollView)
        view.addSubview(activityIndicator)
        scrollView.addSubview(contentTextView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40),
            
            scrollView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: deleteAccountButton.topAnchor, constant: -15),
            
            deleteAccountButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            deleteAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteAccountButton.widthAnchor.constraint(equalToConstant: 200),
            deleteAccountButton.heightAnchor.constraint(equalToConstant: 44),
            
            contentTextView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentTextView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentTextView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentTextView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentTextView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentTextView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Add target for segmented control
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        // Add target for delete account button
        deleteAccountButton.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)
    }
    
    private func setupContent() {
        updateContent()
    }
    
    // MARK: - Actions
    
    @objc private func dismissViewController() {
        dismiss(animated: true)
    }
    
    @objc private func segmentChanged() {
        updateContent()
    }
    
    @objc private func deleteAccountTapped() {
        showDeleteAccountConfirmation()
    }
    
    // MARK: - Content Management
    
    private func updateContent() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            contentTextView.text = getFAQContent()
        case 1:
            contentTextView.text = getPrivacyPolicyContent()
        case 2:
            contentTextView.text = getTermsOfServiceContent()
        default:
            break
        }
        
        // Scroll to top when content changes
        contentTextView.setContentOffset(.zero, animated: false)
    }
    
    private func getFAQContent() -> String {
        return """
        Frequently Asked Questions
        
        Q: What is this app for?
        A: This app is designed to help users with drowsiness detection while driving, providing safety alerts and monitoring features to prevent accidents caused by driver fatigue.
        
        Q: How does the drowsiness detection work?
        A: The app uses advanced facial recognition technology and machine learning algorithms to monitor your eyes, facial expressions, and head movements to detect signs of drowsiness in real-time.
        
        Q: Do I need an internet connection to use the app?
        A: While some features require an internet connection for data synchronization and updates, the core drowsiness detection functionality can work offline.
        
        Q: How accurate is the drowsiness detection?
        A: Our app uses state-of-the-art algorithms with high accuracy rates. However, it should be used as a supplementary safety tool and not as a replacement for proper rest and safe driving practices.
        
        Q: Can I customize the alert settings?
        A: Yes, you can customize various alert settings including alert sensitivity, sound preferences, and notification types through the settings menu.
        
        Q: Is my data secure?
        A: Yes, we take data privacy seriously. All personal data is encrypted and stored securely. Please refer to our Privacy Policy for more details.
        
        Q: What should I do if the app isn't detecting drowsiness correctly?
        A: Ensure proper lighting and camera positioning. You can also calibrate the detection sensitivity in the settings. If issues persist, please contact our support team.
        
        Q: Can multiple users use the app on the same device?
        A: Yes, the app supports multiple user profiles. Each user can have their own customized settings and detection parameters.
        
        Q: How often should I take breaks while driving?
        A: We recommend taking a 15-20 minute break every 2 hours of driving, or whenever you feel tired. The app will also suggest break times based on your driving patterns.
        
        Q: Does the app work in all lighting conditions?
        A: The app works best in adequate lighting conditions. Performance may be reduced in very low light or extremely bright conditions.
        """
    }
    
    private func getPrivacyPolicyContent() -> String {
        return """
        Privacy Policy
        
        Last updated: [Date]
        
        1. Information We Collect
        We collect information you provide directly to us, such as when you create an account, update your profile, or contact us for support.
        
        Types of information we may collect include:
        • Name and email address
        • Profile information
        • Usage data and analytics
        • Device information
        • Camera data for drowsiness detection (processed locally)
        
        2. How We Use Your Information
        We use the information we collect to:
        • Provide and maintain our services
        • Improve drowsiness detection accuracy
        • Send you technical notices and support messages
        • Respond to your comments and questions
        • Analyze usage patterns to improve our app
        
        3. Information Sharing
        We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.
        
        We may share your information in the following situations:
        • With your consent
        • For legal reasons
        • To protect rights and safety
        • During business transfers
        
        4. Data Security
        We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.
        
        5. Data Retention
        We retain your information for as long as necessary to provide our services and fulfill the purposes outlined in this policy.
        
        6. Your Rights
        You have the right to:
        • Access your personal information
        • Correct inaccurate information
        • Delete your account and data
        • Object to processing
        • Data portability
        
        7. Camera and Facial Data
        • Facial recognition data is processed locally on your device
        • We do not store facial images or biometric data on our servers
        • Camera access is only used for drowsiness detection
        • You can disable camera access at any time in device settings
        
        
        8. Changes to This Policy
        We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page.
        
        9. Contact Us
        If you have any questions about this privacy policy, please contact us at [contact email].
        """
    }
    
    private func getTermsOfServiceContent() -> String {
        return """
        Terms of Service
        
        Last updated: [Date]
        
        1. Acceptance of Terms
        By downloading, installing, or using this drowsiness detection app, you agree to be bound by these Terms of Service.
        
        2. Description of Service
        Our app provides drowsiness detection technology to help prevent accidents caused by driver fatigue. The service includes real-time monitoring, alerts, and safety recommendations.
        
        3. User Responsibilities
        You agree to:
        • Use the app responsibly and as a supplementary safety tool
        • Not rely solely on the app for safety while driving
        • Maintain proper rest and follow safe driving practices
        • Provide accurate information when creating your account
        • Comply with all applicable laws and regulations
        
        4. Limitations of Service
        • The app is a supplementary tool and should not replace proper rest
        • Detection accuracy may vary based on lighting and positioning
        • The app cannot guarantee prevention of all drowsiness-related incidents
        • Service availability may be interrupted for maintenance or updates
        
        5. Disclaimer of Warranties
        The app is provided "as is" without warranties of any kind. We do not guarantee that the service will be uninterrupted, secure, or error-free.
        
        6. Limitation of Liability
        To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of the app.
        
        7. User Accounts
        • You are responsible for maintaining the confidentiality of your account
        • You must notify us immediately of any unauthorized use
        • We reserve the right to suspend or terminate accounts that violate these terms
        
        8. Intellectual Property
        All content, features, and functionality of the app are owned by us and are protected by copyright, trademark, and other intellectual property laws.
        
        9. Privacy
        Your privacy is important to us. Please review our Privacy Policy to understand how we collect and use your information.
        
        10. Prohibited Uses
        You may not use the app:
        • For any unlawful purpose or to solicit unlawful activity
        • To violate any international, federal, provincial, or state regulations or laws
        • To transmit or procure the sending of any advertising or promotional material
        • To impersonate or attempt to impersonate another person or entity
        
        11. Termination
        We may terminate or suspend your account immediately, without prior notice, for conduct that we believe violates these Terms of Service.
        
        12. Changes to Terms
        We reserve the right to modify these terms at any time. Changes will be effective immediately upon posting.
        
        13. Governing Law
        These terms shall be governed by and construed in accordance with the laws of [Jurisdiction].
        
        14. Safety Notice
        IMPORTANT: This app is designed to assist with drowsiness detection but should never be considered a substitute for:
        • Adequate rest before driving
        • Safe driving practices
        • Professional medical advice for sleep disorders
        • Taking breaks when feeling tired
        
        Always prioritize your safety and the safety of others on the road.
        
        15. Contact Information
        If you have any questions about these Terms of Service, please contact us at [contact email].
        """
    }
    
    // MARK: - Account Deletion
    
    private func showDeleteAccountConfirmation() {
        let alert = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to permanently delete your account? This action cannot be undone and will remove all your data.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.showFinalConfirmation()
        })
        
        present(alert, animated: true)
    }
    
    private func showFinalConfirmation() {
        let alert = UIAlertController(
            title: "Final Confirmation",
            message: "This will permanently delete your account and all associated data. Type 'DELETE' to confirm:",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Type DELETE to confirm"
            textField.autocapitalizationType = .allCharacters
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm Delete", style: .destructive) { [weak self] _ in
            guard let textField = alert.textFields?.first,
                  let text = textField.text,
                  text.uppercased() == "DELETE" else {
                self?.showAlert(title: "Invalid Confirmation", message: "Please type 'DELETE' exactly to confirm account deletion.")
                return
            }
            self?.deleteAccount()
        })
        
        present(alert, animated: true)
    }
    
    private func deleteAccount() {
        setLoading(true)
        
        guard let user = Auth.auth().currentUser else {
            setLoading(false)
            showAlert(title: "Error", message: "No user is currently signed in.")
            return
        }
        
        // Check if user needs reauthentication
        self.reauthenticateUser { [weak self] success in
            guard let self = self else { return }
            
            if !success {
                self.setLoading(false)
                return
            }
            
            let userId = user.uid
            let db = Firestore.firestore()
            
            // First delete user data from Firestore
            db.collection("users").document(userId).delete { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.setLoading(false)
                        self.showAlert(title: "Error", message: "Failed to delete user data: \(error.localizedDescription)")
                    }
                    return
                }
                
                // Then delete the user account from Firebase Auth
                user.delete { [weak self] error in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.setLoading(false)
                        
                        if let error = error {
                            let nsError = error as NSError
                            // Check if it's a reauthentication error
                            if nsError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                                self.showAlert(title: "Authentication Required", 
                                             message: "For security reasons, please log out and log back in, then try deleting your account again.")
                            } else {
                                self.showAlert(title: "Error", message: "Failed to delete account: \(error.localizedDescription)")
                            }
                            return
                        }
                        
                        // Account successfully deleted
                        self.accountDeletedSuccessfully()
                    }
                }
            }
        }
    }
    
    private func reauthenticateUser(completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        let alert = UIAlertController(
            title: "Verify Your Password",
            message: "For security reasons, please enter your password to confirm account deletion:",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Enter your password"
            textField.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        })
        
        alert.addAction(UIAlertAction(title: "Verify", style: .default) { [weak self] _ in
            guard let password = alert.textFields?.first?.text,
                  !password.isEmpty else {
                self?.showAlert(title: "Invalid Password", message: "Please enter your password.")
                completion(false)
                return
            }
            
            guard let email = user.email else {
                self?.showAlert(title: "Error", message: "Unable to get user email for reauthentication.")
                completion(false)
                return
            }
            
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            
            user.reauthenticate(with: credential) { [weak self] result, error in
                DispatchQueue.main.async {
                    if error != nil {
                        self?.showAlert(title: "Authentication Failed", message: "Invalid password. Please try again.")
                        completion(false)
                        return
                    }
                    
                    completion(true)
                }
            }
        })
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    private func accountDeletedSuccessfully() {
        // Clean up local data
        cleanupLocalData()
        
        // Show success message and navigate to login
        let alert = UIAlertController(
            title: "Account Deleted",
            message: "Your account and all associated data have been permanently deleted.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigateToLogin()
        })
        
        present(alert, animated: true)
    }
    
    private func cleanupLocalData() {
        // Remove locally stored profile image
        let fileURL = getProfileImageFileURL()
        try? FileManager.default.removeItem(at: fileURL)
        
        // Clear any other local user data as needed
        UserDefaults.standard.removeObject(forKey: "userPreferences")
        UserDefaults.standard.synchronize()
    }
    
    private func getProfileImageFileURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("profileImage.jpg")
    }
    
    private func navigateToLogin() {
        dismiss(animated: false) {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.showLoginScreen()
            }
        }
    }
    
    private func setLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            if loading {
                self.activityIndicator.startAnimating()
                self.deleteAccountButton.isEnabled = false
                self.segmentedControl.isUserInteractionEnabled = false
            } else {
                self.activityIndicator.stopAnimating()
                self.deleteAccountButton.isEnabled = true
                self.segmentedControl.isUserInteractionEnabled = true
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
} 
