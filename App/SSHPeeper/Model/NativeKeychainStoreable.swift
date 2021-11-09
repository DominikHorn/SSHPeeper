//
//  NativeKeychainStoreable.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 08.11.21.
//

import Foundation
import Crypto

protocol NativeKeychainStoreable {
  init<Bytes>(x963Representation: Bytes) throws where Bytes: ContiguousBytes
  var x963Representation: Data { get }
}

extension P256.Signing.PrivateKey: NativeKeychainStoreable {}
