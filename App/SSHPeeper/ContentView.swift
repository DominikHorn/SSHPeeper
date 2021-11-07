//
//  ContentView.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 06.11.21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
      VStack {
        Text("Hello, world!")
            .padding()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
