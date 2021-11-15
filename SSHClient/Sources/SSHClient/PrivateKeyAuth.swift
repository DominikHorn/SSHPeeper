//
//  PrivateKeyAuth.swift
//  
//
//  Created by Dominik Horn on 10.11.21.
//

import Foundation
import NIO
import NIOSSH

public final class PrivateKeyAuth: Auth {
  enum AuthFailure: Error {
    case hostKeyDenied
    case authUnimplemented
    case unsuitableAuthMethod
  }
  
  let username: String
  let key: NIOSSHPrivateKey
  
  public init(username: String, key: NIOSSHPrivateKey) {
    self.username = username
    self.key = key
  }
  
  public func nextAuthenticationType(availableMethods: NIOSSHAvailableUserAuthenticationMethods, nextChallengePromise: EventLoopPromise<NIOSSHUserAuthenticationOffer?>) {
    guard availableMethods.contains(.publicKey) else {
      nextChallengePromise.fail(AuthFailure.unsuitableAuthMethod)
      return
    }
    
    let offer = NIOSSHUserAuthenticationOffer(username: username, serviceName: "", offer: .privateKey(.init(privateKey: key)))
    
    nextChallengePromise.succeed(offer)
  }
}
