//
//  StatusBarItem.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 09.11.21.
//

import SwiftUI

// TODO(dominik): localize

struct StatusBarItem: View {
  @ObservedObject var remoteManager: RemoteManager
  
  var body: some View {
    HStack(alignment: .center) {
      if let isUp = remoteManager.isUp {
        Image(systemSymbol: isUp ? .checkmarkCircle : .bolt)
          .resizable()
          .scaledToFit()
          .frame(width: 15, height: 15)
        
        Text(isUp ? "Running" : "Stopped")
      } else {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle())
          .scaleEffect(0.4)
          .frame(width: 15, height: 15)
        
        Text("Loading")
      }
    }
  }
}

