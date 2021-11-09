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
    Group {
      if let isUp = remoteManager.isUp {
        HStack {
          Image(systemSymbol: isUp ? .checkmarkCircle : .bolt)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 15)
          
          Text(isUp ? "Running" : "Stopped")
        }
      } else {
        HStack(spacing: 5) {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .scaleEffect(0.5)
            .frame(width: 20, height: 20)
          Text("Loading")
        }
      }
    }
    .padding(.bottom, 2)
  }
}

