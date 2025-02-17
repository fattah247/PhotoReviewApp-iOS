//
//  SecureStorage.swift
//  PhotoReviewApp
//
//  Created by Muhammad Abdul Fattah on 05/02/25.
//
import Foundation
import Security

struct SecureStorage {
    static func store(key: String, data: Data) -> OSStatus {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete any existing item with the same key.
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    static func retrieve(key: String) -> Data? {
        // Safely unwrap kCFBooleanTrue.
        guard let returnDataValue = kCFBooleanTrue else {
            print("Error: kCFBooleanTrue is unexpectedly nil.")
            return nil
        }
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: returnDataValue,  // safely unwrapped value
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            return dataTypeRef as? Data
        } else {
            print("Error retrieving item: \(status)")
            return nil
        }
    }
}


