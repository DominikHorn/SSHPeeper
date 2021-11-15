//
//  AppDelegate.swift
//  KanbanBar
//
//  Created by Dominik Horn on 16.10.21.
//

import Foundation
import AppKit
import SwiftUI
import SFSafeSymbols
import SSHClient
import Crypto

class AppDelegate: NSObject, NSApplicationDelegate {
  private var popover: NSPopover?
  private var statusBarItem: NSStatusItem?
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    applyConfiguration()
  }
  
  /// Idempotent method that configures this app depending on the current app state
  func applyConfiguration() {
    // Enforce that we are correctly setup
    guard let username = UserDefaults.standard.string(forKey: DefaultsKeys.username),
          !username.isEmpty,
          let host = UserDefaults.standard.string(forKey: DefaultsKeys.host),
          !host.isEmpty,
          let targetProcessName = UserDefaults.standard.string(forKey: DefaultsKeys.targetProcessName)
    else {
      return
    }
    // TODO(dominik): don't duplicate this default value
    let refreshRate = RefreshRate(rawValue: UserDefaults.standard.string(forKey: DefaultsKeys.refreshRate) ?? "") ?? RefreshRate.medium
    let port = UserDefaults.standard.integer(forKey: DefaultsKeys.port)
    
    // Close all settings windows (if exist)
    NSApplication.shared.windows.forEach { window in
      guard let id = window.identifier, id.rawValue.contains(WindowIdentifier.settings.rawValue) else { return }
      window.close()
    }
    
    Task {
      do {
        // recreate connection
        let remoteManager = try await RemoteManager(
          username: username,
          host: host,
          targetProcessName: targetProcessName,
          refreshRate: refreshRate,
          port: port
        )
    
        await MainActor.run {
          // Create and setup status bar item ('button in status bar to toggle popover')
          if statusBarItem == nil {
            let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            statusBarItem.length = 75
            self.statusBarItem = statusBarItem
          }
          
          if let length = statusBarItem?.length, let button = statusBarItem?.button {
            button.action = #selector(togglePopover(_:))
            
            button.subviews.forEach { $0.removeFromSuperview() }
            
            let view = NSHostingView(rootView: StatusBarItem(remoteManager: remoteManager))
            view.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(view)
            view.widthAnchor.constraint(equalToConstant: length).isActive = true
            view.heightAnchor.constraint(equalToConstant: 22).isActive = true
          }
          
          // Create and setup popover ('content ui')
          if popover == nil {
            let popover = NSPopover()
            popover.behavior = .transient
            popover.contentSize = NSSize(width: 400, height: 400)
            self.popover = popover
          }
          
          // recreate remote data screen
          self.popover?.contentViewController = NSHostingController(rootView: RemoteDataScreen(remoteManager: remoteManager))
        }
      } catch {
        // TODO: properly handle this by displaying an error alert or something
        return
      }
    }
  }
  
  @objc private func togglePopover(_ sender: AnyObject?) {
    guard let popover = self.popover, let button = self.statusBarItem?.button, !popover.isShown else {
      return
    }
    
    // Ensure app is active before showing popover. This will allow grabbing focus
    NSApplication.shared.activate(ignoringOtherApps: true)
    
    // show popover
    popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
  }
}
