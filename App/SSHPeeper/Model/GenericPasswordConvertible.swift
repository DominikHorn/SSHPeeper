//
//  GenericPasswordConvertible.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 08.11.21.
//

import Foundation
import Crypto

protocol GenericPasswordConvertible {
  init<D>(rawRepresentation data: D) throws where D: ContiguousBytes
  var rawRepresentation: Data { get }
}

extension Curve25519.Signing.PrivateKey: GenericPasswordConvertible {}
