//
//  KeychainService.swift
//  PockedGuard
//
//  Created by Арсен Дадаев on 27.11.2025.
//

import Security
import CryptoKit
import Foundation

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

protocol KeychainServiceProtocol {
    func saveUserPin(_ pin: String) -> Bool
    func verifyUserPin(_ pin: String) -> Bool
    func deleteUserPin() -> Bool
    func isUserPinSet() -> Bool
}

final class KeychainService: KeychainServiceProtocol {
    // MARK: - Singleton
    static let shared: KeychainService = .init()
    
    // MARK: - Private properties
    private let service: String
    
    private init() {
        self.service = Bundle.main.bundleIdentifier ?? "pockedguard.service"
    }
}

// MARK: - Public methods
extension KeychainService {
    static let userPinKey = "user_authentication_pin"
    static let appLockPinKey = "app_lock_pin"
    
    func saveUserPin(_ pin: String) -> Bool {
        return savePin(pin, forKey: Self.userPinKey)
    }
    
    func verifyUserPin(_ pin: String) -> Bool {
        return verifyPin(pin, forKey: Self.userPinKey)
    }
    
    func deleteUserPin() -> Bool {
        return deletePin(forKey: Self.userPinKey)
    }
    
    func isUserPinSet() -> Bool {
        return pinExists(forKey: Self.userPinKey)
    }
}

// MARK: - PIN Management with Hashing
private extension KeychainService {
    func savePin(_ pin: String, forKey key: String) -> Bool {
        do {
            let hashedPin = try hashPin(pin)
            return save(hashedPin, forKey: key)
        } catch {
            print("Error hashing PIN: \(error)")
            return false
        }
    }
    
    func verifyPin(_ pin: String, forKey key: String) -> Bool {
        guard let storedHash = getPinHash(forKey: key) else {
            return false
        }
        
        do {
            let inputHash = try hashPin(pin)
            return storedHash == inputHash
        } catch {
            print("Error verifying PIN: \(error)")
            return false
        }
    }
    
    func deletePin(forKey key: String) -> Bool {
        return delete(key)
    }
    
    func pinExists(forKey key: String) -> Bool {
        return getPinHash(forKey: key) != nil
    }
    
    // MARK: - Private Methods
    func getPinHash(forKey key: String) -> String? {
        return get(key)
    }
    
    func hashPin(_ pin: String) throws -> String {
        let salt = getSalt() ?? generateAndStoreSalt()
        let saltedPin = pin + salt
        
        guard let data = saltedPin.data(using: .utf8) else {
            throw KeychainError.unexpectedPasswordData
        }
        
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func getSalt() -> String? {
        return get("pin_salt")
    }
    
    func generateAndStoreSalt() -> String {
        let salt = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        _ = save(salt, forKey: "pin_salt")
        return salt
    }
}

// MARK: - Generic Keychain Operations
private extension KeychainService {
    func save(_ value: String, forKey key: String) -> Bool {
        _ = delete(key)
        
        guard let data = value.data(using: .utf8) else {
            return false
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            return true
        } else {
            print("Keychain save error: \(status)")
            return false
        }
    }
    
    func get(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else {
            if status != errSecItemNotFound {
                print("Keychain get error: \(status)")
            }
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func delete(_ key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            return true
        } else {
            print("Keychain delete error: \(status)")
            return false
        }
    }
}
