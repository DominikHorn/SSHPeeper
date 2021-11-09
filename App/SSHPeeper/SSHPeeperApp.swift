//
//  SSHPeeperApp.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 06.11.21.
//

import SwiftUI

@main
struct SSHPeeperApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  var body: some Scene {
    WindowGroup(id: WindowIdentifier.settings.rawValue) {
      SetupScreen(onConfirm: delegate.onConfirmSetup)
        // activate existing window if exists
        .handlesExternalEvents(preferring: [WindowIdentifier.settings.rawValue], allowing: ["*"])
    }
    // create new window if it does not exist
    .handlesExternalEvents(matching: [WindowIdentifier.settings.rawValue])
  }
}

