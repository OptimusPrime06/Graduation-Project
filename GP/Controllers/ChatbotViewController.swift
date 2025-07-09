//
//  ChatbotViewController.swift
//  GP
//
//  Created by Abdelrahman Kafsher on 10/04/2025.
//

import UIKit
import Speech
import AVFoundation

class ChatbotViewController: UIViewController, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var hasSentMessage = false
    
    // MARK: - UI Components
    
    private let chatTextView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 30)
        view.textColor = .black
        view.isEditable = false
        view.isScrollEnabled = true
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        view.textAlignment = .natural // Supports both LTR and RTL
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageField: UITextField = {
        let field = UITextField()
        field.placeholder = "Type message..."
        field.borderStyle = .roundedRect
        field.textAlignment = .left // LTR for English
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let voiceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Talk to Bot 🤖", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let languageToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🇺🇸 EN", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.setTitleColor(.systemBlue, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        return button
    }()
    
    private let microphoneIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 30
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let microphoneIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "mic.fill")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let volumeIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var volumeBars: [UIView] = []
    
    // MARK: - Speech Recognition & Language Support
    private var currentLanguage: String = "en-US" // English as default
    private var speechRecognizer: SFSpeechRecognizer!
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var lastTranscriptTime: Date?
    private var pauseTimer: Timer?
    
    // MARK: - Speech Synthesizer
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var shouldRestartListeningAfterSpeech = false
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Chatbot"
        setupNavigationBar()
        setupSpeechRecognizer()
        setupUI()
        requestSpeechAuthorization()
        updateUIForCurrentLanguage()
        
        // Set speech synthesizer delegate
        speechSynthesizer.delegate = self
        
        // Show welcome message
        showWelcomeMessage()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                view.addGestureRecognizer(tapGesture)
    }
    
    private func showWelcomeMessage() {
        // Show welcome message after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let welcomeMessage = self.currentLanguage.starts(with: "ar") ? 
                "مرحباً، أهلاً بك في البوت الذكي" : 
                "Welcome to the Smart Bot"
            self.appendMessage("🤖 \(welcomeMessage)")
            
            // Don't auto-restart listening for welcome message
            self.shouldRestartListeningAfterSpeech = false
            self.speak(welcomeMessage)
        }
    }
    
    private func setupNavigationBar() {
        // Add language toggle button to navigation bar
        languageToggleButton.addTarget(self, action: #selector(didTapLanguageToggle), for: .touchUpInside)
        let languageBarButtonItem = UIBarButtonItem(customView: languageToggleButton)
        navigationItem.rightBarButtonItem = languageBarButtonItem
    }
    
    private func setupUI() {
        // Background
        let backgroundImage = UIImageView()
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.image = UIImage(named: "backgroundImage")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
        
        // Setup Targets
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        voiceButton.addTarget(self, action: #selector(didTapVoiceButton), for: .touchUpInside)
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [chatTextView, messageField, sendButton, voiceButton, microphoneIndicatorView, volumeIndicatorView].forEach { contentView.addSubview($0) }
        
        // Add microphone icon to indicator view
        microphoneIndicatorView.addSubview(microphoneIconView)
        
        // Create volume bars
        setupVolumeBars()
        
        NSLayoutConstraint.activate([
            // Background
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // ContentView inside ScrollView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Chat TextView
            chatTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            chatTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            chatTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chatTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: UIScreen.main.bounds.height * 0.6),
            
            // Message Field
            messageField.topAnchor.constraint(equalTo: chatTextView.bottomAnchor, constant: 12),
            messageField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            messageField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            messageField.heightAnchor.constraint(equalToConstant: 44),
            
            // Send Button
            sendButton.centerYAnchor.constraint(equalTo: messageField.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sendButton.widthAnchor.constraint(equalToConstant: 70),
            sendButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Voice Button
            voiceButton.topAnchor.constraint(equalTo: messageField.bottomAnchor, constant: 16),
            voiceButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            voiceButton.widthAnchor.constraint(equalToConstant: 200),
            voiceButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Microphone Indicator View
            microphoneIndicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            microphoneIndicatorView.topAnchor.constraint(equalTo: voiceButton.bottomAnchor, constant: 20),
            microphoneIndicatorView.widthAnchor.constraint(equalToConstant: 60),
            microphoneIndicatorView.heightAnchor.constraint(equalToConstant: 60),
            
            // Microphone Icon
            microphoneIconView.centerXAnchor.constraint(equalTo: microphoneIndicatorView.centerXAnchor),
            microphoneIconView.centerYAnchor.constraint(equalTo: microphoneIndicatorView.centerYAnchor),
            microphoneIconView.widthAnchor.constraint(equalToConstant: 30),
            microphoneIconView.heightAnchor.constraint(equalToConstant: 30),
            
            // Volume Indicator View
            volumeIndicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            volumeIndicatorView.topAnchor.constraint(equalTo: microphoneIndicatorView.bottomAnchor, constant: 10),
            volumeIndicatorView.widthAnchor.constraint(equalToConstant: 100),
            volumeIndicatorView.heightAnchor.constraint(equalToConstant: 20),
            volumeIndicatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    
    private func setupVolumeBars() {
        // Create 5 volume indicator bars
        for i in 0..<5 {
            let bar = UIView()
            bar.backgroundColor = .systemGreen
            bar.alpha = 0.3
            bar.layer.cornerRadius = 1
            bar.translatesAutoresizingMaskIntoConstraints = false
            volumeIndicatorView.addSubview(bar)
            volumeBars.append(bar)
            
            NSLayoutConstraint.activate([
                bar.bottomAnchor.constraint(equalTo: volumeIndicatorView.bottomAnchor),
                bar.leadingAnchor.constraint(equalTo: volumeIndicatorView.leadingAnchor, constant: CGFloat(i * 18)),
                bar.widthAnchor.constraint(equalToConstant: 3),
                bar.heightAnchor.constraint(equalToConstant: CGFloat(4 + i * 3))
            ])
        }
    }
    
    private func setupSpeechRecognizer() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: currentLanguage))
        speechRecognizer?.delegate = self
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                print("🚫 Speech recognition not authorized")
            }
        }
    }
    
    private func updateUIForCurrentLanguage() {
        if currentLanguage.starts(with: "ar") {
            // Arabic UI
            messageField.placeholder = "اكتب رسالة..."
            messageField.textAlignment = .right
            sendButton.setTitle("إرسال", for: .normal)
            voiceButton.setTitle("تحدث مع البوت 🤖", for: .normal)
            languageToggleButton.setTitle("🇪🇬 ع", for: .normal)
            title = "البوت الذكي"
        } else {
            // English UI
            messageField.placeholder = "Type message..."
            messageField.textAlignment = .left
            sendButton.setTitle("Send", for: .normal)
            voiceButton.setTitle("Talk to Bot 🤖", for: .normal)
            languageToggleButton.setTitle("🇺🇸 EN", for: .normal)
            title = "Chatbot"
        }
    }
    
    // MARK: - Visual Feedback Animations
    
    private func showMicrophoneIndicator() {
        UIView.animate(withDuration: 0.3) {
            self.microphoneIndicatorView.alpha = 1.0
            self.volumeIndicatorView.alpha = 1.0
        }
        startPulsingAnimation()
        startVolumeAnimation()
    }
    
    private func hideMicrophoneIndicator() {
        UIView.animate(withDuration: 0.3) {
            self.microphoneIndicatorView.alpha = 0.0
            self.volumeIndicatorView.alpha = 0.0
        }
        stopPulsingAnimation()
        stopVolumeAnimation()
    }
    
    private func startPulsingAnimation() {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1.0
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.2
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        microphoneIndicatorView.layer.add(pulseAnimation, forKey: "pulse")
    }
    
    private func stopPulsingAnimation() {
        microphoneIndicatorView.layer.removeAnimation(forKey: "pulse")
    }
    
    private func startVolumeAnimation() {
        // Animate volume bars with random heights to simulate voice activity
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self, self.audioEngine.isRunning else {
                timer.invalidate()
                return
            }
            
            for (_, bar) in self.volumeBars.enumerated() {
                let randomAlpha = Double.random(in: 0.3...1.0)
                UIView.animate(withDuration: 0.1) {
                    bar.alpha = randomAlpha
                }
            }
        }
    }
    
    private func stopVolumeAnimation() {
        // Reset all bars to default state
        for bar in volumeBars {
            UIView.animate(withDuration: 0.2) {
                bar.alpha = 0.3
            }
        }
    }
    
    // MARK: - Button Actions
    
    @objc private func didTapSendButton() {
        guard let text = messageField.text, validateMessage(text) else {
            return
        }
        let userPrefix = currentLanguage.starts(with: "ar") ? "أنت: " : "You: "
        appendMessage("🧍 \(userPrefix)\(text)")
        messageField.text = ""
        sendToChatbot(text)
    }
    
    @objc private func didTapVoiceButton() {
        if audioEngine.isRunning {
            // User manually stopped listening, so don't auto-restart
            shouldRestartListeningAfterSpeech = false
            stopListening()
        } else {
            startListening()
        }
    }
    
    @objc private func didTapLanguageToggle() {
        // Toggle between Arabic and English using configuration constants
        if currentLanguage.starts(with: "ar") {
            currentLanguage = ChatbotConfig.englishLocale
        } else {
            currentLanguage = ChatbotConfig.arabicLocale
        }
        
        setupSpeechRecognizer()
        updateUIForCurrentLanguage()
        
        // Add feedback message
        let message = currentLanguage.starts(with: "ar") ? 
            "اللغة اتغيرت للعربي 🇪🇬" :
            "Language changed to English 🇺🇸"
        appendMessage("ℹ️ \(message)")
    }
    
    // MARK: - Speech Handling
    
    private func startListening() {
        hasSentMessage = false
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let inputNode = audioEngine.inputNode
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { result, error in
            guard let result = result else {
                if let error = error {
                    print("❌ Speech error: \(error.localizedDescription)")
                }
                self.stopListening()
                return
            }
            
            let transcript = result.bestTranscription.formattedString
            print("🎙️ Transcript: \(transcript)")
            
            let cleaned = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Update last transcript time and reset pause timer
            self.lastTranscriptTime = Date()
            self.pauseTimer?.invalidate()
            
            // Send immediately if final, or start pause detection for non-empty transcripts
            if !self.hasSentMessage && !cleaned.isEmpty {
                if result.isFinal {
                    self.sendTranscriptMessage(cleaned)
                } else {
                                         // Start a pause timer using configuration
                     self.pauseTimer = Timer.scheduledTimer(withTimeInterval: ChatbotConfig.pauseDetectionInterval, repeats: false) { _ in
                        if !self.hasSentMessage {
                            self.sendTranscriptMessage(cleaned)
                        }
                    }
                }
            }
        }
        
        
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        let stopTitle = currentLanguage.starts(with: "ar") ? "🛑 توقف" : "🛑 Stop"
        voiceButton.setTitle(stopTitle, for: .normal)
        showMicrophoneIndicator()
        
        // ⏱ Timeout using configuration
        DispatchQueue.main.asyncAfter(deadline: .now() + ChatbotConfig.speechTimeout) {
            if self.audioEngine.isRunning && !self.hasSentMessage {
                self.stopListening()
                print("⏱️ Stopped due to timeout")
            }
        }
        
    }
    
    private func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        audioEngine.inputNode.removeTap(onBus: 0)
        pauseTimer?.invalidate()
        pauseTimer = nil
        
        // Reset audio session for normal playback
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("❌ Error resetting audio session: \(error)")
        }
        
        let voiceTitle = currentLanguage.starts(with: "ar") ? "تحدث مع البوت 🤖" : "Talk to Bot 🤖"
        voiceButton.setTitle(voiceTitle, for: .normal)
        hideMicrophoneIndicator()
    }
    
    private func sendTranscriptMessage(_ message: String) {
        hasSentMessage = true
        let userPrefix = currentLanguage.starts(with: "ar") ? "أنت: " : "You: "
        appendMessage("🧍 \(userPrefix)\(message)")
        stopListening()
        sendToChatbot(message)
    }
    
    // MARK: - Chatbot API
    
    private func sendToChatbot(_ message: String) {
        // Validate configuration
        guard ChatbotConfig.shared.isConfigurationValid else {
            showErrorAlert(ChatbotError.missingConfiguration)
            return
        }
        
        guard let urlString = ChatbotConfig.shared.apiURL,
              let url = URL(string: urlString) else {
            showErrorAlert(ChatbotError.invalidURL)
            return
        }
        
        guard let apiKey = ChatbotConfig.shared.apiKey else {
            showErrorAlert(ChatbotError.invalidAPIKey)
            return
        }
        
        // Validate message
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ Skipping empty message")
            return
        }
        
        let typingMessage = currentLanguage.starts(with: "ar") ? "🤖 البوت يكتب..." : "🤖 Bot is typing..."
        appendMessage(typingMessage)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.timeoutInterval = 30.0
        
        let body: [String: Any] = [
            "userId": UIDevice.current.identifierForVendor?.uuidString ?? "user_default",
            "message": message
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            showErrorAlert(ChatbotError.networkError(error))
            removeLastBotTypingMessage()
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.removeLastBotTypingMessage()
                
                if let error = error {
                    print("❌ API error: \(error.localizedDescription)")
                    self.showErrorAlert(ChatbotError.networkError(error))
                    return
                }
                
                guard let data = data else {
                    print("❌ No data returned")
                    self.showErrorAlert(ChatbotError.noData)
                    return
                }
                
                if let raw = String(data: data, encoding: .utf8) {
                    print("📦 Raw API response: \(raw)")
                }
                
                do {
                    let response = try JSONDecoder().decode(ChatbotResponse.self, from: data)
                    let botPrefix = self.currentLanguage.starts(with: "ar") ? "البوت: " : "Bot: "
                    self.appendMessage("🤖 \(botPrefix)\(response.reply)")
                    
                    // Set flag to restart listening after bot finishes speaking
                    self.shouldRestartListeningAfterSpeech = true
                    self.speak(response.reply)
                } catch {
                    // Fallback to old parsing method
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let reply = json["reply"] as? String {
                        let botPrefix = self.currentLanguage.starts(with: "ar") ? "البوت: " : "Bot: "
                        self.appendMessage("🤖 \(botPrefix)\(reply)")
                        
                        // Set flag to restart listening after bot finishes speaking
                        self.shouldRestartListeningAfterSpeech = true
                        self.speak(reply)
                    } else {
                        print("⚠️ No valid 'reply' field")
                        self.showErrorAlert(ChatbotError.invalidResponse)
                    }
                }
            }
        }.resume()
    }
    
    private func showErrorAlert(_ error: ChatbotError) {
        let alert = UIAlertController(
            title: "Chatbot Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Helpers
    
    private func appendMessage(_ message: String) {
        chatTextView.text += message + "\n\n"
        let bottom = NSRange(location: chatTextView.text.count - 1, length: 1)
        chatTextView.scrollRangeToVisible(bottom)
    }
    
    private func removeLastBotTypingMessage() {
        let typingMessageEn = "🤖 Bot is typing...\n\n"
        let typingMessageAr = "🤖 البوت يكتب...\n\n"
        
        if chatTextView.text.hasSuffix(typingMessageEn) {
            chatTextView.text = String(chatTextView.text.dropLast(typingMessageEn.count))
        } else if chatTextView.text.hasSuffix(typingMessageAr) {
            chatTextView.text = String(chatTextView.text.dropLast(typingMessageAr.count))
        }
    }
    
    private func speak(_ text: String) {
        // Configure audio session for playback
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try audioSession.setActive(true)
        } catch {
            print("❌ Audio session error: \(error)")
        }
        
        let utterance = AVSpeechUtterance(string: text)
        
        // Try to get a voice for the current language, fallback to default
        if let voice = AVSpeechSynthesisVoice(language: currentLanguage) {
            utterance.voice = voice
            print("🔊 Using voice: \(voice.name) for language: \(currentLanguage)")
        } else {
            // Fallback to default voice
            print("⚠️ No voice found for \(currentLanguage), using default")
        }
        
        // Set speech rate based on language using configuration
        if currentLanguage.starts(with: "ar") {
            utterance.rate = ChatbotConfig.arabicSpeechRate
        } else {
            utterance.rate = ChatbotConfig.englishSpeechRate
        }
        
        utterance.volume = 1.0 // Maximum volume
        utterance.pitchMultiplier = 1.0
        
        speechSynthesizer.speak(utterance)
        print("🔊 Speaking: \(text)")
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let bottomInset = keyboardFrame.height
        scrollView.contentInset.bottom = bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
        
        DispatchQueue.main.async {
            let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.height + keyboardFrame.height)
            self.scrollView.setContentOffset(bottomOffset, animated: true)
        }
        
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Cleanup
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopListening()
        pauseTimer?.invalidate()
        hideMicrophoneIndicator()
    }
    
    // MARK: - Input Validation
    private func validateMessage(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= ChatbotConfig.maxMessageLength
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("🔊 Bot finished speaking")
        
        // Automatically restart listening if the flag is set
        if shouldRestartListeningAfterSpeech {
            shouldRestartListeningAfterSpeech = false
            
            // Add a small delay to ensure audio session is properly configured
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startListening()
                print("🎙️ Auto-restarted listening after bot response")
            }
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("🔊 Bot speech was cancelled")
        shouldRestartListeningAfterSpeech = false
    }
    
}
