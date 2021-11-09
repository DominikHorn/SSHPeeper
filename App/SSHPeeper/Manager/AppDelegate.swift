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
  
  func onConfirmSetup() {
    configureViews()
  }
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    configureViews()
  }
}

// MARK: - View Management
extension AppDelegate {
  /// Idempotent method that configures this app's views depending on the current app state
  private func configureViews() {
    // Enforce that we are correctly setup
    guard let username = UserDefaults.standard.string(forKey: DefaultsKeys.username),
          !username.isEmpty,
          let host = UserDefaults.standard.string(forKey: DefaultsKeys.host),
          !host.isEmpty,
          let targetProcessName = UserDefaults.standard.string(forKey: DefaultsKeys.targetProcessName)
    else {
      return
    }
    let port = UserDefaults.standard.integer(forKey: DefaultsKeys.port)
    
    // Close main window (only shown on user request)
    if let window = NSApplication.shared.windows.first {
      window.close()
    }
    
    Task {
      do {
        let remoteManager = try await RemoteManager(username: username, host: host, targetProcessName: targetProcessName, port: port)
    
        await MainActor.run {
          // Create and setup status bar item ('button in status bar to toggle popover')
          let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
          if let button = statusBarItem.button {
            // TODO(dominik): entirely custom view [https://stackoverflow.com/questions/60036391/how-to-draw-custom-view-in-nsstatusbar]
            button.image = NSImage(systemSymbol: .terminal, accessibilityDescription: "Open SSHPeeper's menubar popover")
            button.action = #selector(togglePopover(_:))
          }
          self.statusBarItem = statusBarItem
          
          // Create and setup popover ('content ui')
          let popover = NSPopover()
          popover.behavior = .transient
          popover.contentSize = NSSize(width: 400, height: 400)
          popover.contentViewController = NSHostingController(rootView: RemoteDataScreen(remoteManager: remoteManager))
          self.popover = popover
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
