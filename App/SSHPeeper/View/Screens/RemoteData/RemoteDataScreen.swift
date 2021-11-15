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
  
  @ViewBuilder var header: some View {
    HStack {
      if remoteManager.refreshing {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle())
          .scaleEffect(0.5)
          .frame(width: 20, height: 20)
      }
      
      Spacer()
      
      Button(action: { Task { await remoteManager.refresh() } }) {
        Label("Refresh", systemSymbol: .arrowTriangle2Circlepath)
      }
      
      Button(action: {
        if let url = WindowIdentifier.settings.url {
          openURL(url)
        }
      }) {
        Label("Settings", systemSymbol: .gear)
      }
    }
  }
  
  var body: some View {
    Group {
      if let error = remoteManager.error {
        VStack {
          header
          errorView(error: error)
        }
      } else if showBanner, let banner = remoteManager.bannerMessage {
        VStack {
          header
          Text(banner)
            .font(.system(size: 13).monospaced())
        }
      } else {
        VStack {
          header
          
          Spacer()
          
          HStack {
            CPUUsageView(stats: $remoteManager.processStats)
            MemUsageView(stats: $remoteManager.processStats)
          }
          
          Spacer()
        }
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
  }
}
