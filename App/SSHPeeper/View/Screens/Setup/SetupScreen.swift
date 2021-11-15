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
  @AppStorage(DefaultsKeys.refreshRate) var refreshRate = RefreshRate.medium
  
  let onConfirm: () -> Void
  
  @ViewBuilder var sshAuthView: some View {
    Form {
      TextField("Username:", text: $username)
      TextField("Host:", text: $host)
      TextField("Port:", text: .init(get: { "\(port)" }, set: { port = Int($0.filter({ $0.isNumber })) ?? port }))
    }
    .padding()
  }
  
  @ViewBuilder var targetConfigView: some View {
    Form {
      Section {
        TextField("Target Process Name:", text: $targetProcessName)
        
        Picker("Refresh Rate:", selection: $refreshRate) {
          Text("High").tag(RefreshRate.high)
          Text("Medium").tag(RefreshRate.medium)
          Text("Low").tag(RefreshRate.low)
        }
      }
    }
    .padding()
  }
  
  @ViewBuilder var publicKeyBox: some View {
    if let publicKey = AuthData.openSSHEncodedPublicKey {
      VStack {
        HStack {
          Text("Public SSH Key:")
            .bold()
          
          Spacer()
          Button(action: {
            let pasteboard = NSPasteboard.general
            pasteboard.declareTypes([.string], owner: nil)
            pasteboard.setString(publicKey, forType: .string)
          }) {
            Label("Copy", systemSymbol: .squareAndArrowUp)
          }
        }
        
        Text(publicKey)
          .font(.system(size: 13).monospaced())
          .textSelection(.enabled)
          .help(publicKey)
      }
      .padding()
      .background(RoundedRectangle(cornerRadius: 5).fill(Color.gray.opacity(0.1)))
    }
  }
  
  var body: some View {
    VStack {
      TabView {
        sshAuthView.tabItem {
          Label("SSH Authentication", systemSymbol: .lock)
        }
        .frame(height: 100)
        
        targetConfigView.tabItem {
          Label("Target Configuration", systemSymbol: .gear)
        }
        .frame(height: 100)
      }
      
      publicKeyBox
        .layoutPriority(1)
      
      HStack {
        Spacer()
        Button("Confirm", action: onConfirm)
          .disabled(username.isEmpty || host.isEmpty || targetProcessName.isEmpty)
      }
    }
    .padding()
    .frame(width: 500, height: 350)
  }
}

struct SetupScreen_Previews: PreviewProvider {
    static var previews: some View {
      SetupScreen() {}
    }
}
