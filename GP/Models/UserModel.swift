//
//  UserModel.swift
//  GP
//
//  Created by Gulliver Raed on 3/8/25.
//

import Foundation

enum Gender {
    case Male, Female, unspecified
}

enum AlarmType {
    case sound, flash, both
}

enum AlarmSound: String {
    case scanning, beep, digitalAlarm
    
    var soundFileName : String {
        switch self {
        case .scanning:
            return "Alarm and Beeps Scanning"
        case .beep:
            return "Beep Timer Samsung"
        case .digitalAlarm:
            return "Digital Alarm 884HZ"
        }
    }
}

struct EmergencyContact: Codable {
    var contactName: String
    var number: String
}

struct UserModel {
    
    private(set) var name: String?
    private(set) var email: String?
    private(set) var password: String?
    private(set) var age: Int?
    private(set) var gender: Gender?
    private(set) var experience: String?
    private(set) var choronicDiseases: [String]?
    private(set) var alertType: AlarmSound?
    private(set) var emergencyContacts : [EmergencyContact]?
       
    init(name: String? = nil, email: String? = nil, password: String? = nil, age: Int? = nil, gender: Gender? = nil, experience: String? = nil, choronicDiseases: [String]? = nil, alertType: AlarmSound? = nil, emergencyContacts: [EmergencyContact]? = nil) {
        self.name = name
        self.email = email
        self.password = password
        self.age = age
        self.gender = gender
        self.experience = experience
        self.alertType = alertType
        self.emergencyContacts = emergencyContacts
    }
    
    func getEmail() -> String {
        return self.email!
    }
    
    func getPassword() -> String {
        return self.password!
    }
    
    
    mutating func updateAlertType(newAlertType: AlarmSound) {
        self.alertType = newAlertType
    }
    
    mutating func addEmergencyContact(newContact: EmergencyContact){
        self.emergencyContacts?.append(newContact)
    }
    
    mutating func removeEmergencyContact(contact emergencyContact: EmergencyContact){
        self.emergencyContacts?.removeAll { contact in
            contact.number == emergencyContact.number
            }
    }
    
}

