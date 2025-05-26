//
//  SettingsViewController.swift
//  GP
//
//  Created by Abdelrahman Kafsher on 10/04/2025.
//

import UIKit
<<<<<<< HEAD

class SettingsViewController: UIViewController {

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
import AudioToolbox
import AVFoundation
import Contacts
import ContactsUI

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
    private let systemSounds: [(id: String, name: String)] = [
        ("system_default", "Default Alert"),
        ("system_1000", "Tink"),
        ("system_1001", "Glass"),
        ("system_1002", "Ladder"),
        ("system_1003", "Minuet"),
        ("system_1004", "News Flash"),
        ("system_1006", "Suspense"),
        ("system_1008", "Choo"),
        ("system_1009", "Descending"),
        ("system_1010", "Ascending"),
        ("system_1013", "Notify"),
        ("system_1014", "Tock"),
        ("system_1016", "Whistle")
    ]
    private var customSounds: [(id: String, name: String)] = []
    private var alarmSounds: [(id: String, name: String)] = []
    private var emergencyContacts: [[String: String]] = []
    
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
        alarmSounds = systemSounds + customSounds
        loadEmergencyContacts()
        tableView.reloadData()
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
        emergencyContacts = UserDefaults.standard.emergencyContacts
    }
    
    private func saveEmergencyContacts() {
        UserDefaults.standard.emergencyContacts = emergencyContacts
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
        if id == "system_default" {
            // Play the default system sound
            AudioServicesPlaySystemSound(1304)
        } else if id.hasPrefix("system_") {
            // Extract the sound ID number
            if let soundId = Int(id.replacingOccurrences(of: "system_", with: "")) {
                // Play the system sound
                AudioServicesPlaySystemSound(UInt32(soundId))
            }
        } else {
            // Play custom sound file
            if let soundPath = Bundle.main.path(forResource: id.replacingOccurrences(of: ".wav", with: ""), ofType: "wav") {
                let soundURL = URL(fileURLWithPath: soundPath)
                
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                    audioPlayer?.prepareToPlay()
                    audioPlayer?.volume = 1.0
                    audioPlayer?.play()
                } catch {
                    print("Failed to play sound: \(error)")
                }
            }
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
            cell.accessoryType = sound.id == UserDefaults.standard.selectedAlarmSound ? .checkmark : .none
        } else {
            if indexPath.row == emergencyContacts.count {
                cell.textLabel?.text = "Add Emergency Contact"
                cell.textLabel?.textColor = .systemBlue
                cell.accessoryType = .disclosureIndicator
            } else {
                let contact = emergencyContacts[indexPath.row]
                cell.textLabel?.text = contact["name"]
                cell.detailTextLabel?.text = contact["phone"]
                cell.accessoryType = .none
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
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row < emergencyContacts.count {
            if editingStyle == .delete {
                emergencyContacts.remove(at: indexPath.row)
                saveEmergencyContacts()
                tableView.deleteRows(at: [indexPath], with: .fade)
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
>>>>>>> origin/main3
}
