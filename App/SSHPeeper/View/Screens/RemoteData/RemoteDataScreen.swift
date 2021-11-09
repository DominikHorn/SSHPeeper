//
//  RemoteDataScreen.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 06.11.21.
//

import SwiftUI

struct RemoteDataScreen: View {
  @ObservedObject var remoteManager: RemoteManager
  
  @State private var errorPresented = false
  @State private var showBanner = false
  
  @Environment(\.openURL) var openURL
  
  @ViewBuilder func errorView<T: LocalizedError>(error: T) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 10)
        .fill(Color.red.opacity(0.7))
      
      VStack(alignment: .leading, spacing: 20) {
        Text(error.localizedDescription)
          .font(.title)
        
        if let reason = error.failureReason {
          Text(reason)
            .font(.callout)
        }
      }
      .padding()
    }
  }
  
  var body: some View {
    Group {
      if let error = remoteManager.error {
        errorView(error: error)
      } else if showBanner, let banner = remoteManager.bannerMessage {
        Text(banner)
          .font(.system(size: 13).monospaced())
      } else {
        VStack {
          HStack {
            Button("Refresh") {
              Task {
                await remoteManager.refresh()
              }
            }
            
            Button("Settings") {
              if let url = WindowIdentifier.settings.url {
                openURL(url)
              }
            }
          }
          
          HStack {
            Image(systemSymbol: remoteManager.isUp ? .checkmarkSeal : .xmarkSeal)
            Text("Process is\(remoteManager.isUp ? "" : " not") running")
          }
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
  }
}
