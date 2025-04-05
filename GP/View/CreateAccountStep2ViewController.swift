//
//  CreateAccountStep2ViewController.swift
//  GP
//
//  Created by Gulliver Raed on 3/24/25.
//

import UIKit
import AVKit
import MobileCoreServices

private let backgroundImage = BackgroundImageView()

private let createAccountLabel = StepNumberLabel(stepNumber: 2)

private let progressBarView: SegmentedBarView = {
    let progressView = SegmentedBarView()
    let colors = [
        UIColor(named: Constants.previousPageColor)!,
        UIColor(named: Constants.currentPageColor)!,
        UIColor(named: Constants.nextPageColor)!,
        UIColor(named: Constants.nextPageColor)!
    ]
    let progressViewModel = SegmentedBarView.Model(colors: colors, spacing: 12)
    progressView.setModel(progressViewModel)
    
    progressView.translatesAutoresizingMaskIntoConstraints = false
    
    return progressView
}()

private let videoPreview: UIImageView = {
    let imageView = UIImageView()
    imageView.backgroundColor = .black // Placeholder for video preview
    imageView.contentMode = .scaleAspectFit
    imageView.layer.cornerRadius = 12
    imageView.clipsToBounds = true
    
    imageView.translatesAutoresizingMaskIntoConstraints = false
    
    return imageView
}()

private let recordVideoButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Record Video", for: .normal)
    button.backgroundColor = .systemRed
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 12
    
    button.translatesAutoresizingMaskIntoConstraints = false
    
    return button
}()

private let navigationButtons = NavigationButtons()


class CreateAccountStep2ViewController: UIViewController {

    private var videoURL: URL?
    var step2UserModel : UserModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - Disabiling the Navigation Bar
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        UISetUp()
    }
    
    @objc func nextButtonTapped() {
        let vc = CreateAccountStep3ViewController()
        vc.step3UserModel = self.step2UserModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

}

extension CreateAccountStep2ViewController {
    
    private func UISetUp() {
        view.addSubview(backgroundImage)
        view.addSubview(createAccountLabel)
        view.addSubview(progressBarView)
        view.addSubview(videoPreview)
        view.addSubview(recordVideoButton)
        view.addSubview(navigationButtons)
        
        

        // Background Image Constraints
        let backgroundImageConstraints = [
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(backgroundImageConstraints)
        
        //Step 2 Label Constraints
        let createAccountLabelConstraints = [
            createAccountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            createAccountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createAccountLabel.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        NSLayoutConstraint.activate(createAccountLabelConstraints)
        
        //Progress Bar Constraints
        let progressBarConstraints = [
            progressBarView.topAnchor.constraint(equalTo: createAccountLabel.bottomAnchor, constant: 30),
            progressBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressBarView.heightAnchor.constraint(equalToConstant: 20)
        ]
        
        NSLayoutConstraint.activate(progressBarConstraints)
        
        //Video Preview ImageView Constraints
        let videoPreviewConstraints = [
            videoPreview.topAnchor.constraint(equalTo: progressBarView.bottomAnchor, constant: 20),
            videoPreview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            videoPreview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            videoPreview.heightAnchor.constraint(equalToConstant: 450)
        ]
        
        NSLayoutConstraint.activate(videoPreviewConstraints)
        
        //Recorde Video Button
        let recordVideoButtonConstraints = [
            recordVideoButton.topAnchor.constraint(equalTo: videoPreview.bottomAnchor, constant: 30),
            recordVideoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordVideoButton.widthAnchor.constraint(equalToConstant: 150),
            recordVideoButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(recordVideoButtonConstraints)
        
        // Navigation Buttons
        let navigationButtonsStacViewConstraints = [
            navigationButtons.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            navigationButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            navigationButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            navigationButtons.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(navigationButtonsStacViewConstraints)
        
        
        // Remove any existing targets before adding a new one
        recordVideoButton.removeTarget(nil, action: nil, for: .allEvents)
        navigationButtons.backButton.removeTarget(nil, action: nil, for: .allEvents)
        navigationButtons.nextButton.removeTarget(nil, action: nil, for: .allEvents)
        
        
        //Adding Button Functions
        recordVideoButton.addTarget(self, action: #selector(recordVideo), for: .touchUpInside)
        navigationButtons.nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        navigationButtons.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
    }
    
}

//MARK: - Recording & Displaying Video
extension CreateAccountStep2ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc private func recordVideo() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = [UTType.movie.identifier]
        picker.videoQuality = .typeMedium
        picker.delegate = self
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let videoURL = info[.mediaURL] as? URL {
            self.videoURL = videoURL
            generateThumbnail(from: videoURL)
        }
        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }

    private func generateThumbnail(from url: URL) {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 600)

        DispatchQueue.global().async {
            if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
                let thumbnail = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    videoPreview.image = thumbnail
                    self.addPlayButton()
                }
            }
        }
    }

    private func addPlayButton() {
        let playButton = UIButton(type: .custom)
        playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        playButton.tintColor = .white
        playButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        playButton.center = CGPoint(x: videoPreview.bounds.width / 2, y: videoPreview.bounds.height / 2)
        playButton.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        videoPreview.addSubview(playButton)
    }

    @objc private func playVideo() {
        guard let videoURL = videoURL else { return }
        let player = AVPlayer(url: videoURL)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        present(playerVC, animated: true) {
            player.play()
        }
    }
}

//MARK: - Preview
//#if DEBUG
//    #Preview("Sign Up 2 View") {
//        CreateAccountStep2ViewController()
//    }
//#endif
