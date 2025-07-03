//
//  ChatBotModel.swift
//  GP
//
//  Created by Gulliver Raed on 7/3/25.
//


import Foundation

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
