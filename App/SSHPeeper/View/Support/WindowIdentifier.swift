//
//  WindowIdentifier.swift
//  SSHPeeper
//
//  Created by Dominik Horn on 09.11.21.
//

import Foundation
import AppKit

enum WindowIdentifier: String {
  case settings
  
  var url: URL? {
    URL(string: "sshpeeper://\(rawValue)")
  }
}
