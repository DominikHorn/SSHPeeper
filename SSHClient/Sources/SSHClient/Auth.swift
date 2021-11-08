import Foundation
import NIO
import NIOSSH

public protocol Auth: NIOSSHClientUserAuthenticationDelegate, NIOSSHClientServerAuthenticationDelegate {}

// MARK: default NIOSSHClientServerAuthenticationDelegate implementation
public extension Auth {
  func validateHostKey(hostKey: NIOSSHPublicKey, validationCompletePromise: EventLoopPromise<Void>) {
    // TODO: implement host key validation (load expected key into NIOSSHPublicKey and use ==)
    //    validationCompletePromise.fail(AuthFailure.unknownHost)
    validationCompletePromise.succeed(())
  }
}

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

/*
 TODO:
 else if availableMethods.contains(.password) {
 print("Trying password auth")
 // TODO: implement
 //nextChallengePromise.succeed(.init(username: "", serviceName: "", offer: ))))
 nextChallengePromise.fail(AuthFailure.authUnimplemented)
 }
 */
