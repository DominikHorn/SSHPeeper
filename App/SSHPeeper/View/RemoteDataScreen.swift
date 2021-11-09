//
//  RemoteDataScreen.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 06.11.21.
//

import SwiftUI

struct RemoteDataScreen: View {
  @ObservedObject var remoteManager: RemoteManager
  
  var body: some View {
    VStack {
      Text("Hello, world!")
        .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
  }
}
