//
//  ChatbotViewController.swift
//  GP
//
//  Created by Abdelrahman Kafsher on 10/04/2025.
//

import UIKit
import Speech
import AVFoundation

class ChatbotViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // MARK: - UI Components
    
    private let chatTextView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 16)
        view.textColor = .black // 👈 Add this line
        view.isEditable = false
        view.isScrollEnabled = true
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor(white: 0.95, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageField: UITextField = {
        let field = UITextField()
        field.placeholder = "Type message..."
        field.borderStyle = .roundedRect
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
        button.setTitle("🎤 Talk to AI", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Speech Recognition
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "AI Assistant"
        setupUI()
        requestSpeechAuthorization()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    private func setupUI() {
        // Background
        let backgroundImage = UIImageView()
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.image = UIImage(named: "backgroundImage")
        backgroundImage.contentMode = .scaleAspectFill
        view.insertSubview(backgroundImage, at: 0)
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        
        // Scroll View
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(chatTextView)
        contentView.addSubview(messageField)
        contentView.addSubview(sendButton)
        contentView.addSubview(voiceButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Background
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Chat TextView
            chatTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            chatTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            chatTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chatTextView.heightAnchor.constraint(equalToConstant: 300),
            
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
            voiceButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10) // Important for scroll height
        ])
    }
    
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                print("🚫 Speech recognition not authorized")
            }
        }
    }
    
    // MARK: - Button Actions
    
    @objc private func didTapSendButton() {
        guard let text = messageField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        appendMessage("🧍 You: \(text)")
        messageField.text = ""
        sendToChatbot(text)
    }
    
    @objc private func didTapVoiceButton() {
        if audioEngine.isRunning {
            stopListening()
        } else {
            startListening()
        }
    }
    
    // MARK: - Speech Handling
    
    private func startListening() {
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
            
            if result.isFinal || transcript.split(separator: " ").count >= 3 {
                self.appendMessage("🧍 You: \(transcript)")
                self.stopListening()
                self.sendToChatbot(transcript)
            }
        }
        
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        voiceButton.setTitle("🛑 Stop", for: .normal)
    }
    
    private func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        audioEngine.inputNode.removeTap(onBus: 0)
        voiceButton.setTitle("🎤 Talk to AI", for: .normal)
    }
    
    // MARK: - Chatbot API
    
    private func sendToChatbot(_ message: String) {
        guard let url = URL(string: "https://z8z26r9a8d.execute-api.us-east-1.amazonaws.com/prod/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("aE7xK9qLmNvZbT2jKdQwHfYrP8sLmNvZ", forHTTPHeaderField: "x-api-key")
        
        let body: [String: Any] = [
            "userId": UIDevice.current.identifierForVendor?.uuidString ?? "user_default",
            "message": message
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ No data returned")
                return
            }
            
            if let raw = String(data: data, encoding: .utf8) {
                print("📦 Raw API response: \(raw)")
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let reply = json["reply"] as? String {
                DispatchQueue.main.async {
                    self.appendMessage("🤖 Bot: \(reply)")
                    self.speak(reply)
                }
            } else {
                print("⚠️ No valid 'reply' field")
            }
        }.resume()
    }
    
    // MARK: - Helpers
    
    private func appendMessage(_ message: String) {
        chatTextView.text += message + "\n\n"
        let bottom = NSRange(location: chatTextView.text.count - 1, length: 1)
        chatTextView.scrollRangeToVisible(bottom)
    }
    
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        AVSpeechSynthesizer().speak(utterance)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let bottomInset = keyboardFrame.height
        scrollView.contentInset.bottom = bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
}
