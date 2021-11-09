//
//  SetupScreen.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 09.11.21.
//

import SwiftUI
import SFSafeSymbols

// TODO(dominik): localize strings in this file

struct SetupScreen: View {
  @AppStorage(DefaultsKeys.username) var username = ""
  @AppStorage(DefaultsKeys.host) var host = ""
  @AppStorage(DefaultsKeys.port) var port = 22
  
  @AppStorage(DefaultsKeys.targetProcessName) var targetProcessName = ""
  
  let onConfirm: () -> Void
  
  @ViewBuilder var sshAuthView: some View {
    Form {
      TextField("Username:", text: $username)
      TextField("Host", text: $host)
      TextField("Port", text: .init(get: { "\(port)" }, set: { port = Int($0.filter({ $0.isNumber })) ?? port }))
    }
    .padding()
  }
  
  @ViewBuilder var targetConfigView: some View {
    Form {
      TextField("Target Process Name:", text: $targetProcessName)
    }
    .padding()
  }
  
  var body: some View {
    VStack {
      TabView {
        sshAuthView.tabItem {
          Label("SSH Authentication", systemSymbol: .lock)
        }
        
        targetConfigView.tabItem {
          Label("Target Configuration", systemSymbol: .gear)
        }
      }
      
      HStack {
        Spacer()
        Button("Confirm", action: onConfirm)
          .disabled(username.isEmpty || host.isEmpty || targetProcessName.isEmpty)
      }
    }
    .padding()
    .frame(maxWidth: 512, maxHeight: 256)
  }
}

struct SetupScreen_Previews: PreviewProvider {
    static var previews: some View {
      SetupScreen() {}
    }
}
