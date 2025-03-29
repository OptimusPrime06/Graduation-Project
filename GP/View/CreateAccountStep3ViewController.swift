//
//  CreateAccountStep3ViewController.swift
//  GP
//
//  Created by Gulliver Raed on 3/25/25.
//

import UIKit

private let backgroundImage: UIImageView = {

    let backgroundImage = UIImageView(image: UIImage(named: "backGround"))
    backgroundImage.contentMode = .scaleAspectFill
    backgroundImage.translatesAutoresizingMaskIntoConstraints = false

    return backgroundImage
}()

private let createAccountLabel: UILabel = {

    let createAccountLabel = UILabel()
    createAccountLabel.text = "Step 3"
    createAccountLabel.numberOfLines = 0
    createAccountLabel.font = .systemFont(ofSize: 40, weight: .bold)
    createAccountLabel.textColor = .white

    createAccountLabel.translatesAutoresizingMaskIntoConstraints = false

    return createAccountLabel
}()

private let progressBarView: SegmentedBarView = {

    let progressBarView = SegmentedBarView()
    let colors = [
        UIColor(named: "previousPageColor")!,
        UIColor(named: "previousPageColor")!,
        UIColor(named: "currentPageColor")!,
        UIColor(named: "nextPageColor")!
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
    label.text =
        "Select from these choronic diseases if you have any ( tap on disease to mark it )"
    label.textColor = .white
    label.font = .systemFont(ofSize: 18)
    label.numberOfLines = 3

    label.translatesAutoresizingMaskIntoConstraints = false

    return label
}()

private let conditions = [
    "Only one eye (monocular vision)",
    "Blurry or cloudy vision",
    "Narrow vision (glaucoma)",
    "Blind spots (diabetic eye disease, stroke effects)",
    "Droopy eyelid (ptosis)",
    "Facial burns or scars",
    "Severe eye misalignment",
    "Scars or damage to the cornea ",
    "Seizures (epilepsy)",
    "Tremors & stiff muscles",
    "Sudden sleep attacks (narcolepsy)",
    "Partial face paralysis (stroke or Bell’s palsy)",
    "Sleep apnea (severe snoring & breathing issues)",
    "Severe migraines",
    "Nerve diseases like multiple sclerosis that affect vision & alertness",
    "Extreme fatigue (chronic tiredness)",
    "Severe anxiety",
    "Depression",
    "Diabetes",
    "Autoimmune disease (e.g., lupus)",
    "Facial deformities (conditions affecting facial structure)",
    "Skin patches or color differences (vitiligo if near the eyes)",
    "Low or high thyroid function (causes extreme tiredness)",
]

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

class CreateAccountStep3ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //MARK: - Disabiling the Navigation Bar
        navigationController?.setNavigationBarHidden(true, animated: false)

        tableViewSetUp()
        textViewSetUp()
        UISetUp()
    }
    
    @objc func nextButtonTapped() {
        let vc = CreateAccountStep4ViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func backButtonTapped() {
        let vc = CreateAccountStep2ViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension CreateAccountStep3ViewController {

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

extension CreateAccountStep3ViewController: UITableViewDelegate,
    UITableViewDataSource
{

    private func tableViewSetUp() {
        chronicDiseasesTableView.delegate = self
        chronicDiseasesTableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        conditions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell", for: indexPath)
        let condition = conditions[indexPath.row]
        cell.accessoryType =
            selectedConditions.contains(condition) ? .checkmark : .none
        cell.textLabel?.textColor = .white
        cell.backgroundColor = UIColor(named: "signUpTextFieldBackgroundColor")
        cell.textLabel?.font = .systemFont(ofSize: 14)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = condition
        return cell
    }

    func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: IndexPath
    ) {
        let condition = conditions[indexPath.row]
        if selectedConditions.contains(condition) {
            selectedConditions.remove(condition)
        } else {
            selectedConditions.insert(condition)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}

extension CreateAccountStep3ViewController: UITextViewDelegate {

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

//MARK: - Preview
//#if DEBUG
//    #Preview("Sign Up 3 View") {
//        CreateAccountStep3ViewController()
//    }
//#endif
