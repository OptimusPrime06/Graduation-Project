//
//  test.swift
//  GP
//
//  Created by Gulliver Raed on 3/25/25.
//

import UIKit

class CreateAccountStep3TestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let conditions = [
        "Only one eye (monocular vision)", "Blurry or cloudy vision", "Blind spots", "Facial burns or scars",
        "Severe eye misalignment", "Seizures (epilepsy)", "Tremors & stiff muscles", "Narcolepsy (sleep attacks)",
        "Sleep apnea (severe snoring & breathing issues)", "Extreme fatigue (chronic tiredness)",
        "Severe anxiety", "Depression", "Diabetes", "Autoimmune disease (e.g., lupus)"
    ]
    
    private var selectedConditions: Set<String> = []
    
    private let tableView = UITableView()
    private let otherConditionField = UITextField()
    private let alertPreferenceSegment = UISegmentedControl(items: ["Sound", "Vibration", "Phone Call"])
    private let emergencyNameField = UITextField()
    private let emergencyPhoneField = UITextField()
    private let nextButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Health & Safety Details"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsMultipleSelection = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        otherConditionField.placeholder = "Other condition (if any)"
        otherConditionField.borderStyle = .roundedRect
        otherConditionField.translatesAutoresizingMaskIntoConstraints = false
        
        alertPreferenceSegment.selectedSegmentIndex = 0
        alertPreferenceSegment.translatesAutoresizingMaskIntoConstraints = false
        
        emergencyNameField.placeholder = "Emergency Contact Name"
        emergencyNameField.borderStyle = .roundedRect
        emergencyNameField.translatesAutoresizingMaskIntoConstraints = false
        
        emergencyPhoneField.placeholder = "Emergency Contact Phone"
        emergencyPhoneField.borderStyle = .roundedRect
        emergencyPhoneField.keyboardType = .phonePad
        emergencyPhoneField.translatesAutoresizingMaskIntoConstraints = false
        
        nextButton.setTitle("Next", for: .normal)
        nextButton.backgroundColor = .systemBlue
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.layer.cornerRadius = 8
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [tableView, otherConditionField, alertPreferenceSegment, emergencyNameField, emergencyPhoneField, nextButton])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            tableView.heightAnchor.constraint(equalToConstant: 300),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conditions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let condition = conditions[indexPath.row]
        cell.textLabel?.text = condition
        cell.accessoryType = selectedConditions.contains(condition) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let condition = conditions[indexPath.row]
        if selectedConditions.contains(condition) {
            selectedConditions.remove(condition)
        } else {
            selectedConditions.insert(condition)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    @objc private func nextTapped() {
        // Handle storing selected conditions, emergency contact, and alert preferences
        print("Selected Conditions: \(selectedConditions)")
        print("Other Condition: \(otherConditionField.text ?? "None")")
        print("Alert Preference: \(alertPreferenceSegment.titleForSegment(at: alertPreferenceSegment.selectedSegmentIndex) ?? "None")")
        print("Emergency Contact: \(emergencyNameField.text ?? "N/A") - \(emergencyPhoneField.text ?? "N/A")")
        
        // Proceed to the next step in the app
    }
}

//#Preview(){
//    CreateAccountStep3TestViewController()
//}
