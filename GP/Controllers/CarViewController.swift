//
//  CarViewController.swift
//  GP
//
//  Created by Abdelrahman Kafsher on 10/04/2025.
//

import UIKit
import AVFoundation
import Vision
import AudioToolbox
import FirebaseAuth

class CarViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVAudioPlayerDelegate {
    
    var sequencehandler = VNSequenceRequestHandler()
    var drowsyFrameCounter = 0
    let drowsyThreshold = 10
    var earThreshold: CGFloat = 0.2
    var alarmTimer: Timer?
    var audioPlayer: AVAudioPlayer?
    let statusLabel = UILabel()
    let cameraPreviewView = UIView()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var session: AVCaptureSession?
    
    let startButton = UIButton(type: .system)
    let stopButton = UIButton(type: .system)
    let calibrateButton = UIButton(type: .system)
    
    var shouldRepeatAlarm = false
    var isAlarmPlaying = false
    
    // MARK: - Performance Optimization
    private var frameSkipCounter = 0
    private let frameSkipInterval = 3 // Process every 3rd frame for better performance
    
    // MARK: - Enhanced Visual Feedback
    private let detectionOverlay = UIView()
    private let eyeStatusLabel = UILabel()
    private let alertLevelView = UIView()
    
    // MARK: - User Calibration System
    private var isCalibrating = false
    private var calibrationSamples: [CGFloat] = []
    private var calibrationTimer: Timer?
    private var countdownTimer: Timer?
    private var calibrationProgress = 0.0
    private let calibrationDuration: TimeInterval = 5.0 // 5 seconds
    private var userEARBaseline: CGFloat = 0.25
    private var isCalibrated = false // Track if user has calibrated
    
    // MARK: - Enhanced Alert System
    enum AlertLevel: Int, CaseIterable {
        case none = 0
        case warning = 1
        case critical = 2
        case emergency = 3
        
        var description: String {
            switch self {
            case .none: return "👁️ Alert"
            case .warning: return "⚠️ Slight Drowsiness"
            case .critical: return "🚨 Drowsiness Detected"
            case .emergency: return "🆘 Critical Drowsiness"
            }
        }
        
        var color: UIColor {
            switch self {
            case .none: return .green
            case .warning: return .orange
            case .critical: return .red
            case .emergency: return .purple
            }
        }
    }
    
    private var currentAlertLevel: AlertLevel = .none
    private var warningFrameCounter = 0
    private let warningThreshold = 5
    
    // MARK: - Analytics & Tracking
    private var sessionStartTime: Date?
    private var drowsinessEvents: [(Date, TimeInterval)] = []
    
    // MARK: - Chatbot Navigation
    var drowsinessTimer: Timer?
    var drowsinessStartTime: Date?
    let drowsinessNavigationThreshold: TimeInterval = 3.0 // 3 seconds
    var hasNavigatedToChatbot = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackground()
        setupUI()
        setupEnhancedUI()
        setupSound()
        setupAudioSession()
        loadUserPreferences()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload user preferences in case user has changed
        loadUserPreferences()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = cameraPreviewView.bounds
    }
    
    // MARK: - User Preferences
    private func loadUserPreferences() {
        // Get the current user's unique calibration key
        guard let userKey = getCurrentUserCalibrationKey() else {
            print("⚠️ No user logged in - calibration will not be saved")
            updateUIForCalibrationStatus()
            return
        }
        
        if UserDefaults.standard.object(forKey: userKey) != nil {
            userEARBaseline = CGFloat(UserDefaults.standard.float(forKey: userKey))
            earThreshold = userEARBaseline * 0.75 // 75% of baseline for detection
            isCalibrated = true // User has previously calibrated
            print("✅ Loaded calibration for user: \(userKey) - Threshold: \(earThreshold)")
        } else {
            print("ℹ️ No calibration found for user: \(userKey)")
        }
        
        // Update UI based on calibration status
        updateUIForCalibrationStatus()
    }
    
    private func saveUserPreferences() {
        // Get the current user's unique calibration key
        guard let userKey = getCurrentUserCalibrationKey() else {
            print("⚠️ No user logged in - calibration cannot be saved")
            return
        }
        
        UserDefaults.standard.set(Float(userEARBaseline), forKey: userKey)
        print("✅ Saved calibration for user: \(userKey) - Threshold: \(earThreshold)")
    }
    
    private func getCurrentUserCalibrationKey() -> String? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        // Create a unique key using the user's UID
        return "userEARThreshold_\(currentUser.uid)"
    }
    
    private func updateUIForCalibrationStatus() {
        DispatchQueue.main.async {
            if self.isCalibrated {
                self.startButton.isEnabled = true
                self.startButton.backgroundColor = .systemGreen
                self.startButton.setTitle("Start Monitoring", for: .normal)
                self.calibrateButton.setTitle("Recalibrate", for: .normal)
                self.statusLabel.text = "Ready to Monitor - Calibrated ✅"
                self.statusLabel.textColor = .green
            } else {
                self.startButton.isEnabled = false
                self.startButton.backgroundColor = .systemGray
                self.startButton.setTitle("Calibrate First", for: .disabled)
                self.calibrateButton.setTitle("Calibrate for Me", for: .normal)
                self.statusLabel.text = "Please calibrate your eyes first"
                self.statusLabel.textColor = .orange
            }
            // Ensure start button is visible when updating status (unless monitoring is active)
            if self.session == nil {
                self.startButton.isHidden = false
            }
        }
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
        
        // Start session tracking
        sessionStartTime = Date()
        drowsinessEvents.removeAll()
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Performance optimization: Skip frames
        frameSkipCounter += 1
        if frameSkipCounter < frameSkipInterval {
            return
        }
        frameSkipCounter = 0
        
        guard let pixelbuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let faceRequest = VNDetectFaceLandmarksRequest { request, error in
            guard let result = request.results as? [VNFaceObservation],
                  let face = result.first else {
                DispatchQueue.main.async {
                    self.updateUIForNoFace()
                }
                return
            }
            
            if let landmarks = face.landmarks {
                self.processLandmarks(landmarks, boundingBox: face.boundingBox, confidence: face.confidence)
            }
        }
        try? sequencehandler.perform([faceRequest], on: pixelbuffer)
    }
    
    private func updateUIForNoFace() {
        eyeStatusLabel.text = "👁️ No face detected"
        updateAlertLevel(.none)
    }
    
    //MARK: - Enhanced face landmarks processing
    
    func processLandmarks(_ landmarks: VNFaceLandmarks2D, boundingBox: CGRect, confidence: Float) {
        guard let leftEye = landmarks.leftEye, let _ = landmarks.rightEye else { return }
        
        let ear = computeEAR(for: leftEye)
        
        // Handle calibration mode
        if isCalibrating {
            handleCalibration(ear: ear)
            return
        }
        
        DispatchQueue.main.async {
            // Update enhanced UI
            self.updateDetectionUI(ear: ear, confidence: confidence)
            
            // Eye-only drowsiness detection logic
            if ear < self.earThreshold {
                self.drowsyFrameCounter += 1
                self.warningFrameCounter += 1
                
                // Start drowsiness timer if not already started (preserved logic)
                if self.drowsinessStartTime == nil {
                    self.drowsinessStartTime = Date()
                    print("🕐 Drowsiness detection started")
                }
                
                // Update alert level based on severity
                self.updateAlertLevelBasedOnFrames()
                
            } else {
                self.drowsyFrameCounter = 0
                self.warningFrameCounter = 0
                // Reset drowsiness timer when alert (preserved logic)
                self.resetDrowsinessTimer()
                self.updateAlertLevel(.none)
            }
            
            // Existing alarm logic (preserved)
            if self.drowsyFrameCounter > self.drowsyThreshold {
                self.playAlarm()
                self.statusLabel.text = "⚠️ Drowsiness Detected!"
                self.statusLabel.textColor = .red
                
                // Track drowsiness event
                if let startTime = self.sessionStartTime {
                    let eventDuration = Date().timeIntervalSince(startTime)
                    self.drowsinessEvents.append((Date(), eventDuration))
                }
                
                // Check if 3 seconds have passed and navigate to chatbot (preserved logic)
                self.checkForChatbotNavigation()
                
            } else {
                self.stopAlarm()
                self.statusLabel.text = "Monitoring..."
                self.statusLabel.textColor = .green
            }
        }
    }
    
    // MARK: - Enhanced UI Updates
    
    private func updateDetectionUI(ear: CGFloat, confidence: Float) {
        let earPercentage = Int((1.0 - ear) * 100)
        
        eyeStatusLabel.text = "👁️ Eyes: \(earPercentage)% closed"
        
        // Color coding based on threshold
        eyeStatusLabel.textColor = ear < earThreshold ? .red : .green
        
        // Debug output for eye detection
#if DEBUG
        print("👁️ EAR: \(String(format: "%.3f", ear)) (\(earPercentage)%)")
#endif
    }
    
    private func updateAlertLevelBasedOnFrames() {
        let newLevel: AlertLevel
        
        if drowsyFrameCounter > drowsyThreshold + 10 {
            newLevel = .emergency
        } else if drowsyFrameCounter > drowsyThreshold {
            newLevel = .critical  // Direct to critical for immediate alarm - NO VIBRATION
        } else if warningFrameCounter > warningThreshold && drowsyFrameCounter == 0 {
            newLevel = .warning   // Only show warning if completely alert (no drowsy frames)
        } else {
            newLevel = .none
        }
        
        updateAlertLevel(newLevel)
    }
    
    private func updateAlertLevel(_ level: AlertLevel) {
        guard currentAlertLevel != level else { return }
        
        currentAlertLevel = level
        
        UIView.animate(withDuration: 0.3) {
            self.alertLevelView.backgroundColor = level.color.withAlphaComponent(0.3)
            // Only update status label if not already showing drowsiness detection
            if self.drowsyFrameCounter <= self.drowsyThreshold {
                self.statusLabel.text = level.description
                self.statusLabel.textColor = level.color
            }
        }
        
        switch level {
        case .warning:
            // Gentle vibration ONLY for true warnings (when completely alert)
            if drowsyFrameCounter == 0 {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        case .critical, .emergency:
            // NO VIBRATION - Alarm is handled immediately by main drowsiness detection logic
            break
        case .none:
            break
        }
    }
    
    // MARK: - Calibration System
    
    private func handleCalibration(ear: CGFloat) {
        // Only collect samples if we're actively calibrating (timer is running)
        if calibrationTimer != nil && calibrationTimer!.isValid {
            calibrationSamples.append(ear)
        }
    }
    
    private func finishCalibration() {
        isCalibrating = false
        calibrationTimer?.invalidate()
        calibrationTimer = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        // Check if we have enough samples
        guard calibrationSamples.count > 0 else {
            // Failed calibration - no samples collected
            calibrateButton.isEnabled = true
            calibrateButton.setTitle("Calibrate for Me", for: .normal)
            statusLabel.text = "❌ Calibration failed - no face detected"
            statusLabel.textColor = .red
            
            let alert = UIAlertController(title: "Calibration Failed",
                                          message: "No face was detected during calibration. Please ensure your face is visible and try again.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .default) { _ in
                self.calibrateButtonTapped()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                // Stop camera if calibration is cancelled after failure
                if self.session != nil {
                    self.stopCamera()
                    self.stopButton.isEnabled = false
                    self.updateUIForCalibrationStatus()
                }
            })
            present(alert, animated: true)
            return
        }
        
        // Calculate user's baseline EAR (average of samples)
        let sampleCount = calibrationSamples.count
        userEARBaseline = calibrationSamples.reduce(0, +) / CGFloat(sampleCount)
        earThreshold = userEARBaseline * 0.75 // 75% of baseline for detection
        
        calibrationSamples.removeAll()
        saveUserPreferences()
        
        // Mark as calibrated and enable monitoring
        isCalibrated = true
        updateUIForCalibrationStatus()
        
        // Hide start button after calibration is complete
        startButton.isHidden = true
        
        calibrateButton.isEnabled = true
        calibrateButton.setTitle("Recalibrate", for: .normal)
        
        // Show success feedback with user context
        let userInfo = Auth.auth().currentUser?.email ?? "current user"
        let alert = UIAlertController(title: "Calibration Complete! ✅",
                                      message: "Personalized drowsiness threshold for \(userInfo) has been set to \(String(format: "%.3f", earThreshold)) based on \(sampleCount) samples. You can now start monitoring.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Chatbot Navigation Methods
    
    private func checkForChatbotNavigation() {
        guard let startTime = drowsinessStartTime,
              !hasNavigatedToChatbot else { return }
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        
        if elapsedTime >= drowsinessNavigationThreshold {
            navigateToChatbot()
        }
    }
    
    private func navigateToChatbot() {
        hasNavigatedToChatbot = true
        resetDrowsinessTimer()
        
        // Stop the alarm and camera before navigating
        stopAlarm()
        
        // Navigate to chatbot tab
        guard let tabBarController = self.tabBarController as? MainTabBarViewController else {
            return
        }
        
        // Switch to chatbot tab (index 2)
        tabBarController.selectedIndex = 2
    }
    
    private func resetDrowsinessTimer() {
        drowsinessStartTime = nil
        drowsinessTimer?.invalidate()
        drowsinessTimer = nil
        hasNavigatedToChatbot = false
    }
    
    // MARK: - EAR Calculation
    
    func computeEAR(for eye: VNFaceLandmarkRegion2D) -> CGFloat {
        guard eye.pointCount >= 6 else { return 1.0 } // for calculation
        
        let points = eye.normalizedPoints
        let vertical1 = distance(points[1], points[5])
        let vertical2 = distance(points[2], points[4])
        let horizontal = distance(points[0], points[3])
        
        return (vertical1 + vertical2) / (2.0 * horizontal)
    }
    
    
    
    // MARK: - Enhanced UI Setup
    
    func setupEnhancedUI() {
        // Detection overlay setup
        detectionOverlay.backgroundColor = UIColor.clear
        detectionOverlay.layer.borderWidth = 2
        detectionOverlay.layer.borderColor = UIColor.green.cgColor
        detectionOverlay.layer.cornerRadius = 8
        detectionOverlay.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        // Eye status label setup
        eyeStatusLabel.text = "👁️ Eyes: Detecting..."
        eyeStatusLabel.textColor = .white
        eyeStatusLabel.textAlignment = .center
        eyeStatusLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        eyeStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Alert level view setup
        alertLevelView.backgroundColor = UIColor.green.withAlphaComponent(0.3)
        alertLevelView.layer.cornerRadius = 8
        alertLevelView.translatesAutoresizingMaskIntoConstraints = false
        
        // Calibrate button setup
        calibrateButton.setTitle("Calibrate for Me", for: .normal)
        calibrateButton.backgroundColor = .systemOrange
        calibrateButton.setTitleColor(.white, for: .normal)
        calibrateButton.layer.cornerRadius = 10
        calibrateButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        calibrateButton.translatesAutoresizingMaskIntoConstraints = false
        calibrateButton.addTarget(self, action: #selector(calibrateButtonTapped), for: .touchUpInside)
        
        // Add subviews
        view.addSubview(detectionOverlay)
        view.addSubview(alertLevelView)
        view.addSubview(eyeStatusLabel)
        view.addSubview(calibrateButton)
        
        // Add overlay to camera preview
        cameraPreviewView.addSubview(detectionOverlay)
        
        // Setup constraints for enhanced UI
        NSLayoutConstraint.activate([
            // Alert level view - positioned above status label
            alertLevelView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            alertLevelView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            alertLevelView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            alertLevelView.heightAnchor.constraint(equalToConstant: 8),
            
            // Eye status label - positioned below calibrate button, above camera frame
            eyeStatusLabel.topAnchor.constraint(equalTo: calibrateButton.bottomAnchor, constant: 15),
            eyeStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Calibrate button
            calibrateButton.topAnchor.constraint(equalTo: stopButton.bottomAnchor, constant: 15),
            calibrateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            calibrateButton.widthAnchor.constraint(equalToConstant: 180),
            calibrateButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Detection overlay (centered in camera preview)
            detectionOverlay.centerXAnchor.constraint(equalTo: cameraPreviewView.centerXAnchor),
            detectionOverlay.centerYAnchor.constraint(equalTo: cameraPreviewView.centerYAnchor),
            detectionOverlay.widthAnchor.constraint(equalToConstant: 200),
            detectionOverlay.heightAnchor.constraint(equalToConstant: 150)
        ])
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
        let soundToPlay = selectedSound == "system_default" ? "Digital Alarm 884HZ.wav" : selectedSound
        print("Attempting to play alarm sound: \(soundToPlay)")
        playCustomSound(filename: soundToPlay)
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
            let soundToPlay = selectedSound == "system_default" ? "Digital Alarm 884HZ.wav" : selectedSound
            playCustomSound(filename: soundToPlay)
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
                self.cameraPreviewView.backgroundColor = .clear
            }
        }
    }
    
    // MARK: - Button Actions
    
    @objc func startButtonTapped() {
        // Check if calibrated first
        guard isCalibrated else {
            let alert = UIAlertController(title: "Calibration Required",
                                          message: "Please calibrate your eyes first before starting monitoring.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        guard session == nil else { return }
        
        // Reset drowsiness timer when starting fresh
        resetDrowsinessTimer()
        
        startCamera()
        statusLabel.text = "Monitoring..."
        statusLabel.textColor = .green
        startButton.isHidden = true    // Hide start button while monitoring
        stopButton.isEnabled = true   // Enable stop button
        
        // Reset frame counter and alert level
        frameSkipCounter = 0
        currentAlertLevel = .none
        updateAlertLevel(.none)
    }
    
    @objc func stopButtonTapped() {
        guard session != nil else { return }
        
        // If calibration is in progress, clean up calibration timers
        if isCalibrating {
            isCalibrating = false
            calibrationTimer?.invalidate()
            calibrationTimer = nil
            countdownTimer?.invalidate()
            countdownTimer = nil
            calibrateButton.isEnabled = true
            calibrateButton.setTitle("Calibrate for Me", for: .normal)
        }
        
        stopCamera()
        
        // Reset drowsiness timer when stopping camera
        resetDrowsinessTimer()
        
        DispatchQueue.main.async {
            // Reset UI based on calibration status
            self.updateUIForCalibrationStatus()
            self.startButton.isHidden = false  // Show start button again
            self.stopButton.isEnabled = false
            self.updateAlertLevel(.none)
            
            // Reset enhanced UI
            self.eyeStatusLabel.text = "👁️ Eyes: Stopped"
            
            // Force immediate UI update
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func calibrateButtonTapped() {
        // Start camera if not running for calibration
        if session == nil {
            startCamera()
            // Enable stop button since camera is now running for calibration
            stopButton.isEnabled = true
        }
        
        // Show setup instructions before starting calibration
        let alert = UIAlertController(title: "🎯 Calibration Setup",
                                      message: "Please position yourself comfortably:\n\n• Sit upright and look straight at the camera\n• Keep your eyes open naturally\n• Ensure good lighting on your face\n• Stay still during the 5-second calibration\n\nPress 'Ready' when you're prepared.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ready", style: .default) { _ in
            self.startCalibration()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // If user cancels and camera was started for calibration, stop it
            if self.session != nil && !self.isCalibrated {
                self.stopCamera()
                self.stopButton.isEnabled = false
            }
        })
        present(alert, animated: true)
    }
    
    private func startCalibration() {
        // Clean up any existing timers
        countdownTimer?.invalidate()
        countdownTimer = nil
        calibrationTimer?.invalidate()
        calibrationTimer = nil
        
        isCalibrating = true
        calibrationSamples.removeAll()
        calibrationProgress = 0.0
        calibrateButton.isEnabled = false
        calibrateButton.setTitle("Calibrating...", for: .disabled)
        
        statusLabel.text = "Starting calibration in 3..."
        statusLabel.textColor = .white
        
        // Countdown before starting
        var countdown = 3
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
                self.statusLabel.text = "Starting calibration in \(countdown)..."
            } else {
                timer.invalidate()
                self.countdownTimer = nil
                self.beginCalibrationSampling()
            }
        }
    }
    
    private func beginCalibrationSampling() {
        statusLabel.text = "👁️ Calibrating... Keep looking straight! (0%)"
        statusLabel.textColor = .white
        
        // Start 5-second calibration timer
        calibrationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.calibrationProgress += 0.1
            let percentage = Int((self.calibrationProgress / self.calibrationDuration) * 100)
            self.statusLabel.text = "👁️ Calibrating... Keep looking straight! (\(percentage)%)"
            
            if self.calibrationProgress >= self.calibrationDuration {
                timer.invalidate()
                self.finishCalibration()
            }
        }
    }
    
    // MARK: - Cleanup
    deinit {
        // Clean up timers when view controller is deallocated
        resetDrowsinessTimer()
        alarmTimer?.invalidate()
        calibrationTimer?.invalidate()
        countdownTimer?.invalidate()
        audioPlayer?.stop()
        session?.stopRunning()
    }
}
