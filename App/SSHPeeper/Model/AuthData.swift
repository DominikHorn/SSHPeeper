//
//  AuthData.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 07.11.21.
//

import Foundation
import Crypto
import SSHClient

struct AuthData {
  // Remember to change +PublicKeyExport when touching this value
  typealias PrivateKey = P256.Signing.PrivateKey
 
  var username: String
  
  static var privateKey: PrivateKey = {
    if let key: PrivateKey = try? AuthData.loadKey() {
      return key
    } else {
      let key = PrivateKey()
      try? AuthData.store(key: key)
      return key
    }
  }()
  
  var sshAuth: Auth {
    PrivateKeyAuth(username: username, key: .init(p256Key: Self.privateKey))
  }
}
