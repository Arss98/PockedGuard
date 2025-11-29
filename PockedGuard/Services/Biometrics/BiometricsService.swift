//
//  BiometricAuthenticationService.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 28.11.2025.
//

import UIKit
import LocalAuthentication

protocol BiometricAuthenticationServiceProtocol {
    func isBiometricAvailable(completion: @escaping (Bool) -> Void)
    func authenticateWithCompletion(_ completion: @escaping (Bool, Error?) -> Void)
}

final class BiometricAuthenticationService: BiometricAuthenticationServiceProtocol {
    func isBiometricAvailable(completion: @escaping (Bool) -> Void) {
        let context: LAContext = .init()
        var error: NSError?
        
        let canEvaluate: Bool = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if let error = error, error.code == LAError.biometryNotEnrolled.rawValue || error.code == LAError.biometryNotAvailable.rawValue {
            completion(false)
            return
        }
        
        completion(canEvaluate)
    }
    
    func authenticateWithCompletion(_ completion: @escaping (Bool, Error?) -> Void) {
        let context: LAContext = .init()
        let reason: String = L10n.Pin.bimetricReason
        
        context.localizedFallbackTitle = L10n.Pin.localizedFallbackTitle
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            completion(success, error)
        }
    }
}
