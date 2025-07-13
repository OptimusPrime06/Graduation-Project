//
//  SettingsViewController.swift
//  GP
//
//  Created by Abdelrahman Kafsher on 10/04/2025.
//

import UIKit
import AudioToolbox
import AVFoundation
import Contacts
import ContactsUI
import FirebaseFirestore
import FirebaseAuth

// MARK: - UserDefaults Extension
extension UserDefaults {
    private enum Keys {
        static let selectedAlarmSound = "selectedAlarmSound"
        static let emergencyContacts = "emergencyContacts"
    }
    
    var selectedAlarmSound: String {
        get {
            return string(forKey: Keys.selectedAlarmSound) ?? "system_default"
        }
        set {
            set(newValue, forKey: Keys.selectedAlarmSound)
        }
    }
    
    var emergencyContacts: [[String: String]] {
        get {
            return array(forKey: Keys.emergencyContacts) as? [[String: String]] ?? []
        }
        set {
            set(newValue, forKey: Keys.emergencyContacts)
        }
    }
}

class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var audioPlayer: AVAudioPlayer?
    private var customSounds: [(id: String, name: String)] = []
    private var alarmSounds: [(id: String, name: String)] = []
    private var emergencyContacts: [[String: String]] = []
    private let db = Firestore.firestore()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioSession()
        setupUI()
        setupTableView()
        loadEmergencyContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCustomSounds()
        // Combine system sounds and custom sounds
        alarmSounds = customSounds
        loadEmergencyContacts()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    private func loadCustomSounds() {
        // Get all sound files from the main bundle
        if let resourcePath = Bundle.main.resourcePath {
            do {
                // Get all files in the resource path
                let allFiles = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                
                // Filter for sound files
                let soundFiles = allFiles.filter { $0.hasSuffix(".mp3") || $0.hasSuffix(".wav") }
                
                // Add custom sounds to the array
                customSounds = soundFiles.map { filename in
                    // Remove file extension for display name
                    let name = filename.replacingOccurrences(of: ".mp3", with: "")
                        .replacingOccurrences(of: ".wav", with: "")
                        .replacingOccurrences(of: "_", with: " ")
                        .capitalized
                    return (filename, name)
                }
            } catch {
                print("Error loading sounds: \(error)")
            }
        }
    }
    
    private func loadEmergencyContacts() {
        guard let user = Auth.auth().currentUser else { return }
        
        db.collection("users").document(user.uid).getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error loading emergency contacts: \(error)")
                return
            }
            
            if let data = document?.data(),
               let contacts = data["emergencyContacts"] as? [[String: String]] {
                DispatchQueue.main.async {
                    self?.emergencyContacts = contacts
                    self?.tableView.reloadData()
                }
            } else {
                // If no emergency contacts array exists, create one
                self?.db.collection("users").document(user.uid).setData([
                    "emergencyContacts": []
                ], merge: true) { error in
                    if let error = error {
                        print("Error creating emergency contacts array: \(error)")
                    }
                }
            }
        }
    }
    
    private func saveEmergencyContacts() {
        guard let user = Auth.auth().currentUser else { return }
        
        db.collection("users").document(user.uid).setData([
            "emergencyContacts": emergencyContacts
        ], merge: true) { error in
            if let error = error {
                print("Error saving emergency contacts: \(error)")
            }
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func playSound(id: String) {
        // To ensure only one sound plays at a time, all alarm sounds must be custom .wav or .mp3 files in the app bundle.
        // System sounds (AudioServicesPlaySystemSound) cannot be stopped/interrupted, so we do not use them here.
        audioPlayer?.stop()
        audioPlayer = nil
        // Try both .wav and .mp3 extensions for flexibility
        let baseId = id.replacingOccurrences(of: ".wav", with: "").replacingOccurrences(of: ".mp3", with: "")
        if let soundPath = Bundle.main.path(forResource: baseId, ofType: "wav") ?? Bundle.main.path(forResource: baseId, ofType: "mp3") {
            let soundURL = URL(fileURLWithPath: soundPath)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.prepareToPlay()
                audioPlayer?.volume = 1.0
                audioPlayer?.play()
            } catch {
                print("Failed to play sound: \(error)")
            }
        } else {
            print("Sound file not found: \(id)")
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add background image
        let backgroundImage = UIImageView()
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.image = UIImage(named: "backgroundImage")
        backgroundImage.contentMode = .scaleAspectFill
        view.addSubview(backgroundImage)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SoundCell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let label = UILabel()
        label.text = section == 0 ? "Alarm Sound" : "Emergency Contacts"
        label.font = .boldSystemFont(ofSize: 24)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return alarmSounds.count
        } else {
            return emergencyContacts.count + 1 // +1 for "Add Contact" cell
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SoundCell", for: indexPath)
        cell.backgroundColor = .systemBackground.withAlphaComponent(0.8)
        
        // Reset text color to default for all cells
        cell.textLabel?.textColor = .label
        
        if indexPath.section == 0 {
            let sound = alarmSounds[indexPath.row]
            cell.textLabel?.text = sound.name
            cell.detailTextLabel?.text = nil // Reset detail text for alarm sounds section
            cell.accessoryType = sound.id == UserDefaults.standard.selectedAlarmSound ? .checkmark : .none
            cell.accessoryView = nil // Reset accessory view for alarm sounds section
        } else {
            if indexPath.row == emergencyContacts.count {
                cell.textLabel?.text = "Add Emergency Contact"
                cell.textLabel?.textColor = .systemBlue
                cell.detailTextLabel?.text = nil // Reset detail text for "Add Contact" cell
                cell.accessoryType = .disclosureIndicator
                cell.accessoryView = nil // Reset accessory view for "Add Contact" cell
            } else {
                let contact = emergencyContacts[indexPath.row]
                cell.textLabel?.text = contact["name"]
                cell.detailTextLabel?.text = contact["phone"]
                
                // Add a phone icon to indicate this contact can be called
                if #available(iOS 13.0, *) {
                    let phoneImage = UIImage(systemName: "phone.fill")
                    let imageView = UIImageView(image: phoneImage)
                    imageView.tintColor = .systemGreen
                    cell.accessoryView = imageView
                } else {
                    cell.accessoryType = .detailButton
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let sound = alarmSounds[indexPath.row]
            playSound(id: sound.id)
            UserDefaults.standard.selectedAlarmSound = sound.id
            tableView.reloadData()
        } else {
            if indexPath.row == emergencyContacts.count {
                requestContactsAccess()
            } else {
                // Handle emergency contact tap - make phone call
                let contact = emergencyContacts[indexPath.row]
                if let phoneNumber = contact["phone"] {
                    makeEmergencyCall(to: phoneNumber)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Only allow editing in emergency contacts section and not for "Add Contact" row
        if indexPath.section == 1 && indexPath.row < emergencyContacts.count {
            // Only allow deletion if there are more than 2 contacts
            return emergencyContacts.count > 2
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row < emergencyContacts.count {
            if editingStyle == .delete {
                // Double check minimum contacts rule
                if emergencyContacts.count > 2 {
                    emergencyContacts.remove(at: indexPath.row)
                    saveEmergencyContacts()
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } else {
                    showMinimumContactsAlert()
                }
            }
        }
    }
    
    // MARK: - Contacts
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
    
    private func showMinimumContactsAlert() {
        let alert = UIAlertController(
            title: "Minimum Contacts Required",
            message: "You must have at least 2 emergency contacts for safety purposes. Add more contacts before deleting this one.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func makeEmergencyCall(to phoneNumber: String) {
        // Clean the phone number by removing spaces, dashes, parentheses, and other non-numeric characters
        let cleanedNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        // Create the tel URL
        guard let phoneURL = URL(string: "tel:\(cleanedNumber)") else {
            showCallErrorAlert()
            return
        }
        
        // Check if the device can make phone calls
        if UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:]) { success in
                if !success {
                    DispatchQueue.main.async {
                        self.showCallErrorAlert()
                    }
                }
            }
        } else {
            showCallErrorAlert()
        }
    }
    
    private func showCallErrorAlert() {
        let alert = UIAlertController(
            title: "Unable to Make Call",
            message: "This device cannot make phone calls or the phone number is invalid.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - CNContactPickerDelegate
extension SettingsViewController: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        guard let phoneNumber = contact.phoneNumbers.first?.value.stringValue else { return }
        
        let contactInfo: [String: String] = [
            "name": "\(contact.givenName) \(contact.familyName)",
            "phone": phoneNumber
        ]
        
        emergencyContacts.append(contactInfo)
        saveEmergencyContacts()
        tableView.reloadData()
    }
}
