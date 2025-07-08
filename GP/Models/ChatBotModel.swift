//
//  ChatBotModel.swift
//  GP
//
//  Created by Gulliver Raed on 7/3/25.
//


import Foundation

// MARK: - ChatBot Configuration
struct ChatbotConfig {
    static let shared = ChatbotConfig()
    
    private init() {}
    
    var apiURL: String? {
        return Bundle.main.object(forInfoDictionaryKey: "ChatbotAPIURL") as? String
    }
    
    var apiKey: String? {
        return Bundle.main.object(forInfoDictionaryKey: "ChatbotAPIKey") as? String
    }
    
    var isConfigurationValid: Bool {
        return apiURL != nil && apiKey != nil
    }
    
    // Configuration constants
    static let pauseDetectionInterval: TimeInterval = 2.0
    static let maxMessageLength = 500
    static let speechTimeout: TimeInterval = 15.0
    
    // Language constants
    static let arabicLocale = "ar-EG"
    static let englishLocale = "en-US"
    
    // Speech rate constants (0.0 = very slow, 0.5 = normal, 1.0 = very fast)
    static let arabicSpeechRate: Float = 0.5  // Slightly slower for Arabic clarity
    static let englishSpeechRate: Float = 0.5  // Normal speed (iOS default)
}

// MARK: - ChatBot Error Types
enum ChatbotError: Error, LocalizedError {
    case missingConfiguration
    case invalidAPIKey
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case noData
    
    var errorDescription: String? {
        switch self {
        case .missingConfiguration:
            return "Chatbot configuration is missing. Please check your app settings."
        case .invalidAPIKey:
            return "Invalid API key. Please contact support."
        case .invalidURL:
            return "Invalid server URL. Please try again later."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server. Please try again."
        case .noData:
            return "No data received from server. Please try again."
        }
    }
}

// MARK: - Chat Message Model
struct ChatMessage {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp: Date
    
    init(text: String, isFromUser: Bool) {
        self.text = text
        self.isFromUser = isFromUser
        self.timestamp = Date()
    }
}

// MARK: - API Response Model
struct ChatbotResponse: Codable {
    let reply: String
    let userId: String?
}

func sendMessageToChatbot(userInput: String, completion: @escaping (String?) -> Void) {
    guard let url = URL(string: "https://z8z26r9a8d.execute-api.us-east-1.amazonaws.com/prod") else {
        completion("Invalid API URL")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("aZ7XK9qLmNvZbTzjKdQwHfYrP8sLmNvZ", forHTTPHeaderField: "x-api-key") // 🔑 Replace with your actual key

    let body: [String: Any] = [
        "message": userInput,
        "userId": "yehia123" // optional – can be dynamic
    ]

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
    } catch {
        completion("Failed to encode message")
        return
    }

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion("Network error: \(error.localizedDescription)")
            return
        }

        guard let data = data else {
            completion("No data in response")
            return
        }

        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
               let reply = json["reply"] {
                completion(reply)
            } else {
                completion("Unexpected response format")
            }
        } catch {
            completion("Failed to decode response")
        }
    }.resume()
}
