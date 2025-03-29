//
//  UserModel.swift
//  GP
//
//  Created by Gulliver Raed on 3/8/25.
//

import Foundation

struct UserModel {
    let name: String
    let email: String
    private var password : String {
        return updatablePassword
    }
    private(set) var updatablePassword: String
    let age: Int
    let gender: String
    let experience: String
    let userFaceInput: Data?
    private(set) var alertType: String
    private(set) var emergencyPhoneNum: [String]

    mutating func updateAlertType(newAlert: String) {
        alertType = newAlert
    }
    
    mutating func updateEmegencyNumber ( newNumber : String, index: Int ) {
        emergencyPhoneNum[index] = newNumber
    }
    
    mutating func updatePassword( newPassword : String) {
        updatablePassword = newPassword
    }
}
