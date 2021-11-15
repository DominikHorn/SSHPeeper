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
import Combine
import DequeModule

@MainActor
class RemoteManager: ObservableObject {
  @Published var isUp: Bool? = nil
  @Published var output: String? = nil
  @Published var bannerMessage: String? = nil
  @Published var error: RemoteError? = nil
  
  @Published var refreshing = false
  
  @Published var processRuntimeInSeconds = 0
  @Published var processStats = Deque<ProcessStats>(repeating: .init(), count: 100)
  
  private let targetProcessName: String
  private let auth: AuthData
  private var client: SSHClient<RemoteManager>? = nil
  
  private var timer: AnyCancellable? = nil
  
  init(username: String, host: String, targetProcessName: String, refreshRate: RefreshRate, port: Int = 22) throws {
    self.targetProcessName = targetProcessName
    self.auth = AuthData(username: username)
    
    Task {
      do {
        self.client = try await .init(host: host, port: port, auth: auth.sshAuth, delegate: self)
        await refresh()
        
        timer = Timer.publish(every: refreshRate.seconds, on: .main, in: .default)
          .autoconnect()
          .sink { [unowned self] _ in
            Task {
              await self.refresh()
            }
          }
      } catch {
        display(error: error)
      }
    }
  }
  
  /// refresh data by querying server
  func refresh() async {
    // we can't refresh without a client
    guard let client = client else { return }
    
    refreshing = true
    do {
      let (code, psOut) = try await client.execute("ps -u \(auth.username) -o %cpu,%mem,times,comm | grep \(targetProcessName)")
      refreshing = false
      
      self.isUp = code == 0
      self.output = psOut
      
      guard code == 0,
              let lineSubstr = psOut.split(separator: "\n").first else { return }
      let stats = String(lineSubstr).split(separator: " ")
      guard stats.count >= 3,
            let cpuRaw = Double(String(stats[0])),
            let memRaw = Double(String(stats[1])),
            let runtimeRaw = Int(String(stats[2])) else { return }
      
      processRuntimeInSeconds = runtimeRaw
      _ = processStats.popFirst()
      processStats.append(.init(cpuPercent: cpuRaw / 100.0, memoryPercent: memRaw / 100.0))
    } catch {
      refreshing = false
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
