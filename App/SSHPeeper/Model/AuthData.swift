//
//  AuthData.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 07.11.21.
//

import Foundation
import Crypto
import SSHClient

class AuthData {
  typealias PrivateKey = P256.Signing.PrivateKey
  let privateKey: PrivateKey
  let username: String
  
  var sshAuth: Auth {
    PrivateKeyAuth(username: username, key: .init(p256Key: privateKey))
  }
  
  init(username: String) throws {
    self.username = username
    // Load privateKey
    if let key: AuthData.PrivateKey = try Self.loadKey() {
      self.privateKey = key
    } else {
      self.privateKey = .init()
      try Self.store(key: privateKey)
    }
  }
}
