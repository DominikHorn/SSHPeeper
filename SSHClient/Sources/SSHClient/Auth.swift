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

/*
 TODO:
 else if availableMethods.contains(.password) {
 print("Trying password auth")
 // TODO: implement
 //nextChallengePromise.succeed(.init(username: "", serviceName: "", offer: ))))
 nextChallengePromise.fail(AuthFailure.authUnimplemented)
 }
 */
