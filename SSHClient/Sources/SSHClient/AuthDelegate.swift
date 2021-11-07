import Foundation
import NIO
import NIOSSH

final class AuthDelegate {
  enum AuthFailure: Error {
    case unknownHost
    case authUnimplemented
    case unsuitableAuthMethod
  }
}

// MARK: - NIOSSHClientUserAuthenticationDelegate
extension AuthDelegate: NIOSSHClientUserAuthenticationDelegate {
  func nextAuthenticationType(availableMethods: NIOSSHAvailableUserAuthenticationMethods, nextChallengePromise: EventLoopPromise<NIOSSHUserAuthenticationOffer?>) {
    if availableMethods.contains(.publicKey) {
      // TODO: implement
      //nextChallengePromise.succeed(.init(username: "", serviceName: "", offer: ))))
      nextChallengePromise.fail(AuthFailure.authUnimplemented)
    } else if availableMethods.contains(.password) {
      // TODO: implement
      //nextChallengePromise.succeed(.init(username: "", serviceName: "", offer: ))))
      nextChallengePromise.fail(AuthFailure.authUnimplemented)
    } else {
      nextChallengePromise.fail(AuthFailure.unsuitableAuthMethod)
    }
  }
  
}

// MARK: - NIOSSHClientServerAuthenticationDelegate
extension AuthDelegate: NIOSSHClientServerAuthenticationDelegate {
  func validateHostKey(hostKey: NIOSSHPublicKey, validationCompletePromise: EventLoopPromise<Void>) {
    // TODO: implement host key validation
    validationCompletePromise.fail(AuthFailure.unknownHost)
  }
}
