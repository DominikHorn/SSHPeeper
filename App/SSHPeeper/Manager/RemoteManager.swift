//
//  RemoteManager.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 06.11.21.
//

import Foundation
import SSHClient
import SwiftUI

@MainActor
class RemoteManager: ObservableObject {
  @Published var isUp = false
  @Published var bannerMessage: String? = nil
  @Published var error: Error? = nil
  
  
  /* TODO: automate public key retrieval: (currently manual using)
   ```swift
   print(auth.privateKey.publicKey.pemRepresentation)
   ssh-keygen -i -m PKCS8 -f public-key.pem
   ```
   */
  
  private let targetProcessName: String
  private let auth: AuthData
  private var client: SSHClient? = nil
  
  init(username: String, host: String, targetProcessName: String, port: Int = 22) throws {
    self.targetProcessName = targetProcessName
    self.auth = try AuthData(username: username)
    
    Task {
      self.client = try await .init(host: host, auth: auth.sshAuth, delegate: self)
      await refresh()
    }
  }
  
  /// refresh data by querying server
  func refresh() async {
    // we can't refresh without a client
    guard let client = client else { return }
    
    do {
      // TODO: don't hardcode request
      let (code, psOut) = try await client.execute("ps -u \(auth.username) | grep \(targetProcessName)")
      
      print(psOut)
      print("process exited: \(code)")
    } catch {
      display(error: error)
    }
  }
  
  internal func display(banner: String) {
    withAnimation {
      self.bannerMessage = banner
    }
  }
  
  internal func display(error: Error) {
    withAnimation {
      self.error = error
    }
  }
}

extension RemoteManager: SSHClientDelegate {
  func onBanner(message: String) async {
    display(banner: message)
  }
  
  func onError(error: Error) async {
    display(error: error)
  }
}
