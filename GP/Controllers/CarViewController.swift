//
//  CarViewController.swift
//  GP
//
//  Created by Abdelrahman Kafsher on 10/04/2025.
//

import UIKit
import AVFoundation
import Vision
import AudioToolbox

class CarViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVAudioPlayerDelegate {
    
    var sequencehandler = VNSequenceRequestHandler()
    var drowsyFrameCounter = 0
    let drowsyThreshold = 10
    var earThreshold: CGFloat = 0.2
    let marThreshold: CGFloat = 0.5
    var alarmTimer: Timer?
    var audioPlayer: AVAudioPlayer?
    let statusLabel = UILabel()
    let cameraPreviewView = UIView()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var session: AVCaptureSession?
    
    let startButton = UIButton(type: .system)
    let stopButton = UIButton(type: .system)
    
    var shouldRepeatAlarm = false
    var isAlarmPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackground()
        setupUI()
        setupSound()
        setupAudioSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = cameraPreviewView.bounds
    }
    
    
    //MARK: - Camera Setup
    
    func startCamera() {
        session = AVCaptureSession()
        session?.sessionPreset = .medium
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              let session = session else { return }
        
        session.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Video Queue"))
        session.addOutput(output)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        cameraPreviewView.layer.addSublayer(previewLayer)
        
        //update previewLayer frame on main thread
        DispatchQueue.main.async {
            self.previewLayer.frame = self.cameraPreviewView.bounds
        }
        
        //Start session on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
        self.cameraPreviewView.backgroundColor = .clear
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelbuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let faceRequest = VNDetectFaceLandmarksRequest { request, error in
            guard let result = request.results as? [VNFaceObservation],
                  let face = result.first else { return }
            
            if let landmarks = face.landmarks {
                self.processLandmarks(landmarks, boundingBox: face.boundingBox)
            }
        }
        try? sequencehandler.perform([faceRequest], on: pixelbuffer)
    }
    
    //MARK: - face landmarks processing
    
    func processLandmarks(_ landmarks: VNFaceLandmarks2D, boundingBox: CGRect) {
        guard let leftEye = landmarks.leftEye, let rightEye = landmarks.rightEye, let innerLips = landmarks.innerLips else { return }
        
        let ear = computeEAR(for: leftEye)
        let mar = computeMAR(for: innerLips)
        
        DispatchQueue.main.async {
            if ear < self.earThreshold || mar > self.marThreshold {
                self.drowsyFrameCounter += 1
            } else {
                self.drowsyFrameCounter = 0
            }
            
            if self.drowsyFrameCounter > self.drowsyThreshold {
                self.playAlarm()
                self.statusLabel.text = "⚠️ Drowsiness Detected!"
                self.statusLabel.textColor = .red
            } else {
                self.stopAlarm()
                self.statusLabel.text = "Monitoring..."
                self.statusLabel.textColor = .green
            }
        }
    }
    
    // MARK: - EAR Calculation
    
    func computeEAR(for eye: VNFaceLandmarkRegion2D) -> CGFloat {
        guard eye.pointCount >= 6 else { return 1.0 } // عشان الحساب
        
        let points = eye.normalizedPoints
        let vertical1 = distance(points[1], points[5])
        let vertical2 = distance(points[2], points[4])
        let horizontal = distance(points[0], points[3])
        
        return (vertical1 + vertical2) / (2.0 * horizontal)
    }
    
    // MARK: - MAR Calculation
    
    func computeMAR(for mouth: VNFaceLandmarkRegion2D) -> CGFloat {
        guard mouth.pointCount >= 8 else { return 0.0 }
        
        let points = mouth.normalizedPoints
        let vertical = distance(points[2], points[6]) + distance(points[3], points[7])
        let horizontal = distance(points[0], points[4])
        
        return vertical / (2.0 * horizontal)
    }
    
    
    
    func setupUI() {
        statusLabel.text = "Tap Start to Monitor"
        statusLabel.textColor = .orange
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.boldSystemFont(ofSize: 20)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cameraPreviewView.translatesAutoresizingMaskIntoConstraints = false
        //cameraPreviewView.backgroundColor = .clear
        
        startButton.setTitle("Start Monitoring", for: .normal)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.backgroundColor = .systemGreen
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 10
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        //startButton.isEnabled = false
        
        stopButton.setTitle("Stop Camera", for: .normal)
        stopButton.backgroundColor = .systemRed
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.layer.cornerRadius = 10
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.addTarget(self, action: #selector(stopButtonTapped), for: .touchUpInside)
        //stopButton.isEnabled = false
        
        view.addSubview(statusLabel)
        view.addSubview(cameraPreviewView)
        view.addSubview(startButton)
        view.addSubview(stopButton)
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 5),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            cameraPreviewView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 250),
            cameraPreviewView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cameraPreviewView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cameraPreviewView.heightAnchor.constraint(equalTo: cameraPreviewView.widthAnchor),
            
            startButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 180),
            startButton.heightAnchor.constraint(equalToConstant: 44),
            
            stopButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 15),
            stopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopButton.widthAnchor.constraint(equalToConstant: 180),
            stopButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func setupBackground() {
        // Add background image
        let backgroundImage = UIImageView()
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.image = UIImage(named: "backgroundImage")
        backgroundImage.contentMode = .scaleAspectFill
        view.addSubview(backgroundImage)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // Background image constraints
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        let dx = p1.x - p2.x
        let dy = p1.y - p2.y
        return sqrt(dx*dx + dy*dy)
    }
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func setupSound() {
        // No need to create custom sound buffer anymore
        // We'll use system sounds directly
    }
    
    func playAlarm() {
        if isAlarmPlaying { return }
        isAlarmPlaying = true
        shouldRepeatAlarm = true
        let selectedSound = UserDefaults.standard.selectedAlarmSound
        print("Attempting to play alarm sound: \(selectedSound)")
        playCustomSound(filename: selectedSound)
    }
    
    private func playCustomSound(filename: String) {
        audioPlayer?.stop()
        audioPlayer = nil

        DispatchQueue.main.async {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers])
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to set up audio session for alarm: \(error)")
            }

            let url: URL?
            if let dotIndex = filename.lastIndex(of: ".") {
                let name = String(filename[..<dotIndex])
                let ext = String(filename[filename.index(after: dotIndex)...])
                if let path = Bundle.main.path(forResource: name, ofType: ext) {
                    url = URL(fileURLWithPath: path)
                } else {
                    url = nil
                }
            } else {
                if let path = Bundle.main.path(forResource: filename, ofType: "wav") ?? Bundle.main.path(forResource: filename, ofType: "mp3") {
                    url = URL(fileURLWithPath: path)
                } else {
                    url = nil
                }
            }

            if let soundURL = url {
                print("Playing sound at path: \(soundURL.path)")
                do {
                    self.audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                    self.audioPlayer?.delegate = self
                    self.audioPlayer?.prepareToPlay()
                    self.audioPlayer?.volume = 1.0
                    self.audioPlayer?.play()
                } catch {
                    print("Failed to play sound: \(error)")
                    // Fallback: play a system vibration
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                }
            } else {
                print("Sound file not found: \(filename)")
                // Fallback: play a system vibration
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Repeat the alarm if drowsiness is still detected
        if shouldRepeatAlarm && isAlarmPlaying {
            let selectedSound = UserDefaults.standard.selectedAlarmSound
            playCustomSound(filename: selectedSound)
        }
    }
    
    func stopAlarm() {
        if !isAlarmPlaying { return }
        isAlarmPlaying = false
        shouldRepeatAlarm = false
        DispatchQueue.main.async {
            self.alarmTimer?.invalidate()
            self.alarmTimer = nil
            self.audioPlayer?.stop()
            self.audioPlayer = nil
        }
    }
    
    func stopCamera() {
        session?.stopRunning()
        session = nil
        stopAlarm()
        DispatchQueue.main.async {
            self.previewLayer.removeFromSuperlayer()
            UIView.animate(withDuration: 0.3) {
                self.cameraPreviewView.backgroundColor = .black
            }
        }
    }
    
    @objc func startButtonTapped() {
        guard session == nil else { return }
        startCamera()
        statusLabel.text = "Monitoring..."
        statusLabel.textColor = .green
        startButton.isEnabled = false // Disable start button while running
        stopButton.isEnabled = true   // Enable stop button
    }
    
    @objc func stopButtonTapped() {
        guard session != nil else { return }
        stopCamera()
        
        DispatchQueue.main.async {
            self.statusLabel.text = "Camera Stopped"
            self.statusLabel.textColor = .gray
            self.startButton.isEnabled = true
            self.stopButton.isEnabled = false
            
            // Force immediate UI update
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: - Preview

//#if DEBUG
//#Preview("Car View"){
//    CarViewController()
//}
//#endif
