//
//  UserModel.swift
//  GP
//
//  Created by Gulliver Raed on 3/8/25.
//

import Foundation

class UserModel {
    
    private var name: String?
    private var email: String?
    private var password: String? {
        return updatablePassword
    }
    var updatablePassword : String?
    private var age: Int?
    private var gender: String?
    private var experience: String?
    private var userFaceInput: Data?
    private var alertType: String?
    private var emergencyPhoneNum: [String?] = []

    // MARK: - Getters

    func getName() -> String? {
        return name
    }

    func getEmail() -> String? {
        return email
    }

    func getAge() -> Int? {
        return age
    }

    func getGender() -> String? {
        return gender
    }

    func getExperience() -> String? {
        return experience
    }

    func getFaceInputData() -> Data? {
        return userFaceInput
    }

    func getAlertType() -> String? {
        return alertType
    }

    func getEmergencyNumbers() -> [String?] {
        return emergencyPhoneNum
    }


    // MARK: - Setters

    func setName(_ name: String) {
        self.name = name
    }

    func setEmail(_ email: String) {
        self.email = email
    }

    func setAge(_ age: Int) {
        self.age = age
    }

    func setGender(_ gender: String) {
        self.gender = gender
    }

    func setExperience(_ experience: String) {
        self.experience = experience
    }

    func setFaceInputData(_ data: Data) {
        self.userFaceInput = data
    }

    func setAlertType(_ alert: String) {
        self.alertType = alert
    }

    func setEmergencyNumbers(_ numbers: [String?]) {
        self.emergencyPhoneNum = numbers
    }

    func updateEmergencyNumber(_ number: String, at index: Int) {
        if index < emergencyPhoneNum.count {
            emergencyPhoneNum[index] = number
        } else {
            // Add empty slots if needed
            while emergencyPhoneNum.count < index {
                emergencyPhoneNum.append(nil)
            }
            emergencyPhoneNum.append(number)
        }
    }

    func setPassword(_ newPassword: String) {
        // You could hash here in real use cases
        self.updatablePassword = newPassword
    }
}

