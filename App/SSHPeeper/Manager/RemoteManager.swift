//
//  RemoteManager.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 06.11.21.
//

import Foundation
import SSHClient
import SwiftUI
import NIOPosix

@MainActor
class RemoteManager: ObservableObject {
  @Published var isUp: Bool? = nil
  @Published var output: String? = nil
  @Published var bannerMessage: String? = nil
  @Published var error: RemoteError? = nil
  
  
  /* TODO: automate public key retrieval: (currently manual using)
   ```swift
   print(auth.privateKey.publicKey.pemRepresentation)
   ssh-keygen -i -m PKCS8 -f public-key.pem
   ```
   */
  private let targetProcessName: String
  private let refreshRate: RefreshRate
  private let auth: AuthData
  private var client: SSHClient? = nil
  
  init(username: String, host: String, targetProcessName: String, refreshRate: RefreshRate, port: Int = 22) throws {
    self.targetProcessName = targetProcessName
    self.auth = try AuthData(username: username)
    self.refreshRate = refreshRate
    
    Task {
      do {
        self.client = try await .init(host: host, port: port, auth: auth.sshAuth, delegate: self)
        await refresh()
      } catch {
        display(error: error)
      }
    }
  }
  
  /// refresh data by querying server
  func refresh() async {
    // we can't refresh without a client
    guard let client = client else { return }
    
    do {
      // TODO: don't hardcode request
      let (code, psOut) = try await client.execute("ps -u \(auth.username) | grep \(targetProcessName)")
      
      self.isUp = code == 0
      self.output = psOut
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
      self.error = RemoteError(error: error)
    }
  }
}

// MARK: - SSHClientDelegate
extension RemoteManager: SSHClientDelegate {
  func onBanner(message: String) async {
    display(banner: message)
  }
  
  func onError(error: Error) async {
    display(error: error)
  }
}

// MARK: - RemoteError
extension RemoteManager {
  struct RemoteError: LocalizedError {
    var error: Error
    
    var errorDescription: String? {
      if let localizedError = error as? LocalizedError {
        return localizedError.errorDescription
      }
      
      return "\(error.localizedDescription)"
    }
    
    var failureReason: String? {
      if let localizedError = error as? LocalizedError {
        return localizedError.failureReason
      }
      
      return "\(error)"
    }
    
    var helpAnchor: String? {
      if let localizedError = error as? LocalizedError {
        return localizedError.helpAnchor
      }
      
      return nil
    }
    
    var recoverySuggestion: String? {
      if let localizedError = error as? LocalizedError {
        return localizedError.recoverySuggestion
      }
      
      return nil
    }
  }
}
