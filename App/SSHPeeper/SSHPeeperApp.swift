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
    WindowGroup {
      SetupScreen(onConfirm: delegate.onConfirmSetup)
    }
  }
}

