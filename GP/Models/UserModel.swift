//
//  UserModel.swift
//  GP
//
//  Created by Gulliver Raed on 3/8/25.
//

import Foundation

class UserModel {

    // MARK: - User Basic Info
    private var name: String?
    private var email: String?
    private var updatablePassword: String?
    private var age: Int?
    private var gender: String?
    private var experience: String?

    // MARK: - Face Recognition Data
    private var userFaceInput: Data?

    // MARK: - Alerts
    private var alertType: String?
    private var preferredAlerts: [String] = []

    // MARK: - Health Info
    private var diseases: String?
    private var conditions: [String] = []
    private var otherConditions: String?

    // MARK: - Emergency Contacts
    private var emergencyContacts: [[String: String]] = []

    // MARK: - Getters

    func getName() -> String? {
        return name
    }

    func getEmail() -> String? {
        return email
    }

    func getPassword() -> String? {
        return updatablePassword
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

    func getPreferredAlerts() -> [String] {
        return preferredAlerts
    }

    func getDiseases() -> String? {
        return diseases
    }

    func getConditions() -> [String] {
        return conditions
    }

    func getOtherConditions() -> String? {
        return otherConditions
    }

    func getEmergencyContacts() -> [[String: String]] {
        return emergencyContacts
    }

    // MARK: - Setters

    func setName(_ name: String) {
        self.name = name
    }

    func setEmail(_ email: String) {
        self.email = email
    }

    func setPassword(_ newPassword: String) {
        self.updatablePassword = newPassword
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

    func setPreferredAlerts(_ alerts: [String]) {
        self.preferredAlerts = alerts
    }

    func setDiseases(_ diseases: String) {
        self.diseases = diseases
    }

    func setConditions(_ conditions: [String]) {
        self.conditions = conditions
    }

    func setOtherConditions(_ other: String) {
        self.otherConditions = other
    }

    func setEmergencyContacts(_ contacts: [[String: String]]) {
        self.emergencyContacts = contacts
    }
}
