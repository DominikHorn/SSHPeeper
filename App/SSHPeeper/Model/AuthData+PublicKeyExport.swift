//
//  AuthData+PublicKeyExport.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 10.11.21.
//

import Foundation
import NIO
import NIOSSH
import Crypto
import ASN1Parser
import BigInt

extension AuthData {
  static var openSSHEncodedPublicKey: String? = {
    try? OpenSSHP256ECCKey(p256: AuthData.privateKey.publicKey).openSSHFormat
  }()
  
  internal struct OpenSSHP256ECCKey {
    let name = "ecdsa-sha2-nistp256"
    let identifier = "nistp256"
    var q: Data
    
    init(p256: P256.Signing.PublicKey) throws {
      let pem = p256.pemRepresentation
      
      // obtain pem data blob
      precondition(pem.split(separator: "\n").count > 2)
      let encodedPemData = pem
        .split(separator: "\n")
        .dropFirst()
        .dropLast()
        .joined()
      
      guard let pemData = Data(base64Encoded: encodedPemData) else {
        throw ImportError.invalidPEM
      }
      
      let value = try DERParser.parse(der: pemData)
      let bitString = try value.asSequence[1].asBitString
      guard bitString.paddingLength == 0 else {
        // afaik impossible since output is OCTET STRING which can't have padding
        throw ImportError.illegalEncoding
      }

      self.q = .init(bitString.bytes)
    }
    
    var openSSHFormat: String {
      "\(name) \(base64) \(Host.current().localizedName ?? "SSHPeeper")"
    }
    
    var base64: String {
      var buf = Data()
      write(name, to: &buf)
      write(identifier, to: &buf)
      write(q, to: &buf)
      
      return buf.base64EncodedString()
    }
    
    private func write<T: FixedWidthInteger>(_ int: T, to buffer: inout Data) {
      let bytePtr = withUnsafePointer(to: int.bigEndian) {
        $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<T>.size) {
          UnsafeBufferPointer(start: $0, count: MemoryLayout<T>.size)
        }
      }
      buffer += [UInt8](bytePtr)
    }
    
    private func write(_ string: String, to buffer: inout Data) {
      write(UInt32(string.count), to: &buffer)
      buffer += string.utf8.map { $0 }
    }
    
    private func write(_ data: Data, to buffer: inout Data) {
      write(UInt32(data.count), to: &buffer)
      buffer += data
    }
    
    enum ImportError: Error {
      case invalidPEM
      case illegalEncoding
    }
  }
}
