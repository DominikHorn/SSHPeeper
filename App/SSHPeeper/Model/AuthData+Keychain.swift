//
//  AuthData+Keychain.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 08.11.21.
//

import Foundation

extension AuthData {
  enum KeychainError: Error {
    case encodeError
    case decodeError(description: String)
    case storeError(description: String)
    case loadError(description: String)
  }
  
  internal static var keychainLabel: String {
    "\(Bundle.main.bundleIdentifier ?? "de.dhorn.keychain").keys.private-key"
  }
  
  internal static func store<T: NativeKeychainStoreable>(key: T) throws {
    let attributes = [
      kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
      kSecAttrKeyClass: kSecAttrKeyClassPrivate
    ] as [String: Any]
    
    guard let secKey = SecKeyCreateWithData(key.x963Representation as CFData, attributes as CFDictionary, nil) else {
      throw KeychainError.encodeError
    }
    
    let query = [
      kSecClass: kSecClassKey,
      kSecAttrApplicationLabel: keychainLabel,
      kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
      kSecUseDataProtectionKeychain: true,
      kSecValueRef: secKey
    ] as [String: Any]
    
    // Add the key to the keychain.
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
      throw KeychainError.storeError(description: "Unable to store item: \(status)")
    }
  }
  
  internal static func store<T: GenericPasswordConvertible>(key: T) throws {
    let query = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: keychainLabel,
      kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
      kSecUseDataProtectionKeychain: true,
      kSecValueData: key.rawRepresentation
    ] as [String: Any]
    
    // Add the key data.
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
      throw KeychainError.storeError(description: "Unable to store item: \(status)")
    }
  }
  
  internal static func loadKey<T: NativeKeychainStoreable>() throws -> T? {
    let query = [
      kSecClass: kSecClassKey,
      kSecAttrApplicationLabel: keychainLabel,
      kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
      kSecUseDataProtectionKeychain: true,
      kSecReturnRef: true
    ] as [String: Any]
    
    var item: CFTypeRef?
    var secKey: SecKey
    switch SecItemCopyMatching(query as CFDictionary, &item) {
    case errSecSuccess:
      secKey = item as! SecKey
    case errSecItemNotFound:
      return nil
    case let status:
      throw KeychainError.loadError(description: "Keychain read failed: \(status)")
    }
    
    var error: Unmanaged<CFError>?
    guard let data = SecKeyCopyExternalRepresentation(secKey, &error) as Data? else {
      throw KeychainError.decodeError(description: error.debugDescription)
    }
    return try T(x963Representation: data)
  }
  
  internal static func loadKey<T: GenericPasswordConvertible>() throws -> T? {
    // Seek a generic password with the given account.
    let query = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: keychainLabel,
      kSecUseDataProtectionKeychain: true,
      kSecReturnData: true
    ] as [String: Any]
    
    // Find and cast the result as data.
    var item: CFTypeRef?
    switch SecItemCopyMatching(query as CFDictionary, &item) {
    case errSecSuccess:
      guard let data = item as? Data else { return nil }
      return try T(rawRepresentation: data)  // Convert back to a key.
    case errSecItemNotFound:
      return nil
    case let status:
      throw KeychainError.loadError(description: "Keychain read failed: \(status)")
    }
  }
}


