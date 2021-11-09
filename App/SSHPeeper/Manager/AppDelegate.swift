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
    // Close main app window TODO: only do this once app is setup!
    if let window = NSApplication.shared.windows.first {
      window.close()
    }

    // TODO: to get public key that can be added to server, write pem & convert using
    
    /* ```swift
        print(auth.privateKey.publicKey.pemRepresentation)
        ssh-keygen -i -m PKCS8 -f public-key.pem
       ```
     */
    
    // TODO: tmp
    class SSHDelegate: SSHClientDelegate {
      func onBanner(message: String) {
        // TODO: proper handling
        print(message)
      }
      
      func onError(error: Error) {
        print(error)
      }
    }
    
    Task {
      do {
        let delegate = SSHDelegate()
        let auth = try AuthData(username: "dominik")
        let client = try await SSHClient(host: "mcgraw.rm.cab", port: 54245, auth: auth.sshAuth, delegate: delegate)
        let (code, text) = try await client.execute("ps -u dominik")
    
        print(text)
        print("process exited: \(code)")
      } catch {
        print("Received: \(error.localizedDescription)")
      }
    }

//    // Create and setup status bar item ('button in status bar to toggle popover')
//    let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
//    if let button = statusBarItem.button {
//      // TODO(dominik): entirely custom view [https://stackoverflow.com/questions/60036391/how-to-draw-custom-view-in-nsstatusbar]
//      button.image = NSImage(systemSymbol: .terminal, accessibilityDescription: "SSHPeeper")
//      button.action = #selector(togglePopover(_:))
//    }
//    self.statusBarItem = statusBarItem
//
//    // Create and setup popover ('content ui')
//    let popover = NSPopover()
//    popover.behavior = .transient
//    popover.contentSize = NSSize(width: 400, height: 400)
//    popover.contentViewController = NSHostingController(rootView: ContentView())
//    self.popover = popover
  }
  
  @objc func togglePopover(_ sender: AnyObject?) {
    guard let popover = self.popover, let button = self.statusBarItem?.button, !popover.isShown else {
      return
    }
    
    // Ensure app is active before showing popover. This will allow grabbing focus
    NSApplication.shared.activate(ignoringOtherApps: true)
    
    // show popover
    popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
  }
}
