//
//  StatusBarItem.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 09.11.21.
//

import SwiftUI

struct StatusBarItem: View {
    @ObservedObject var remoteManager: RemoteManager
  
    var body: some View {
      HStack {
        Image(systemSymbol: remoteManager.isUp ? .checkmarkCircle : .bolt)
          .resizable()
          .scaledToFit()
          .frame(maxHeight: 15)
        
        Text(remoteManager.isUp ? "Running" : "Stopped")
          .font(.system(size: 13, weight: .light))
      }
      .padding(.bottom, 2)
    }
}
